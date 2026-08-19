#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "net/http"
require "openssl"
require "uri"

class AppStoreConnectClient
  API_ROOT = "https://api.appstoreconnect.apple.com/v1"

  def initialize(key_id:, issuer_id:, key_path:)
    @key_id = key_id
    @issuer_id = issuer_id
    @private_key = OpenSSL::PKey.read(File.read(key_path))
  end

  def get(path, allow_not_found: false)
    response = request(Net::HTTP::Get, path)
    return nil if allow_not_found && response.code.to_i == 404

    ensure_success!(response, [200])
    JSON.parse(response.body)
  end

  def get_all(path)
    items = []
    next_url = absolute_url(path)
    while next_url
      response = request(Net::HTTP::Get, next_url)
      ensure_success!(response, [200])
      document = JSON.parse(response.body)
      items.concat(document.fetch("data"))
      next_url = document.dig("links", "next")
    end
    items
  end

  def post(path, payload)
    response = request(Net::HTTP::Post, path, payload)
    ensure_success!(response, [201])
    JSON.parse(response.body)
  end

  def patch(path, payload)
    response = request(Net::HTTP::Patch, path, payload)
    ensure_success!(response, [200, 204])
    response.body.to_s.empty? ? nil : JSON.parse(response.body)
  end

  def upload(operation, bytes)
    uri = URI(operation.fetch("url"))
    method = operation.fetch("method")
    raise "Unsupported upload method #{method}" unless method == "PUT"

    request = Net::HTTP::Put.new(uri)
    Array(operation["requestHeaders"]).each do |header|
      request[header.fetch("name")] = header.fetch("value")
    end
    request.body = bytes
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    ensure_success!(response, [200, 201])
  end

  private

  def request(method_class, path, payload = nil)
    uri = URI(absolute_url(path))
    request = method_class.new(uri)
    request["Authorization"] = "Bearer #{token}"
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(payload) if payload
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
  end

  def absolute_url(path)
    path.start_with?("http") ? path : "#{API_ROOT}#{path}"
  end

  def token
    now = Time.now.to_i
    header = base64url(JSON.generate(alg: "ES256", kid: @key_id, typ: "JWT"))
    payload = base64url(JSON.generate(iss: @issuer_id, iat: now - 20, exp: now + 900, aud: "appstoreconnect-v1"))
    signing_input = "#{header}.#{payload}"
    sequence = OpenSSL::ASN1.decode(
      @private_key.dsa_sign_asn1(OpenSSL::Digest::SHA256.digest(signing_input))
    )
    raw_signature = sequence.value.map { |integer| integer.value.to_s(2).rjust(32, "\0") }.join
    "#{signing_input}.#{base64url(raw_signature)}"
  end

  def base64url(value)
    Base64.urlsafe_encode64(value).delete("=")
  end

  def ensure_success!(response, expected)
    return if expected.include?(response.code.to_i)

    begin
      document = JSON.parse(response.body)
      details = Array(document["errors"]).map { |error| error["detail"] || error["title"] }.compact.join(" | ")
    rescue JSON::ParserError
      details = response.body.to_s[0, 500]
    end
    raise "App Store Connect #{response.code}: #{details}"
  end
end

def require_env(name)
  value = ENV[name]
  raise "Missing required environment variable #{name}" if value.nil? || value.empty?

  value
end

def asset_state(resource)
  delivery = resource.dig("attributes", "assetDeliveryState")
  delivery.is_a?(Hash) ? delivery["state"] : delivery
end

def upload_asset(client:, resource_type:, relationship_name:, relationship_type:, relationship_id:, path:)
  bytes = File.binread(path)
  reservation = client.post(
    "/#{resource_type}",
    data: {
      type: resource_type,
      attributes: { fileName: File.basename(path), fileSize: bytes.bytesize },
      relationships: {
        relationship_name => { data: { type: relationship_type, id: relationship_id } }
      }
    }
  ).fetch("data")

  Array(reservation.dig("attributes", "uploadOperations")).each do |operation|
    offset = operation.fetch("offset").to_i
    length = operation.fetch("length").to_i
    part = bytes.byteslice(offset, length)
    raise "Invalid upload byte range for #{path}" unless part && part.bytesize == length

    client.upload(operation, part)
  end

  resource_id = reservation.fetch("id")
  client.patch(
    "/#{resource_type}/#{resource_id}",
    data: {
      type: resource_type,
      id: resource_id,
      attributes: { uploaded: true, sourceFileChecksum: Digest::MD5.hexdigest(bytes) }
    }
  )

  deadline = Time.now + 240
  loop do
    resource = client.get("/#{resource_type}/#{resource_id}").fetch("data")
    state = asset_state(resource)
    return resource if state == "COMPLETE"
    raise "#{File.basename(path)} failed processing: #{resource.dig('attributes', 'assetDeliveryState').inspect}" if state == "FAILED"
    raise "Timed out processing #{File.basename(path)} (#{state})" if Time.now >= deadline

    sleep 4
  end
end

app_id = ENV.fetch("TAROT_APP_ID", "6800144105")
version_string = ENV.fetch("TAROT_VERSION", "1.0")
screenshot_directory = ARGV.fetch(0, "store/app-review-assets/en-US/iphone-6.9")
subscription_screenshot = ARGV.fetch(1, "store/app-review-assets/subscriptions/support-subscriptions-review-1260x2736.png")
expected_products = %w[
  com.krazel.tarotdeck.support.monthly.099
  com.krazel.tarotdeck.support.monthly.299
  com.krazel.tarotdeck.support.monthly.499
  com.krazel.tarotdeck.support.monthly.999
  com.krazel.tarotdeck.support.monthly.1499
  com.krazel.tarotdeck.support.monthly.2999
  com.krazel.tarotdeck.support.monthly.50
].freeze

screenshots = Dir.glob(File.join(screenshot_directory, "*.png")).sort
raise "Expected exactly 8 public screenshots, found #{screenshots.length}" unless screenshots.length == 8
raise "Missing subscription review screenshot" unless File.file?(subscription_screenshot)

client = AppStoreConnectClient.new(
  key_id: require_env("APP_STORE_CONNECT_API_KEY_ID"),
  issuer_id: require_env("APP_STORE_CONNECT_ISSUER_ID"),
  key_path: require_env("APP_STORE_CONNECT_API_KEY_PATH")
)

versions = client.get_all(
  "/apps/#{app_id}/appStoreVersions?filter[platform]=IOS&filter[versionString]=#{URI.encode_www_form_component(version_string)}&fields[appStoreVersions]=versionString,appStoreState,platform&limit=200"
)
version = versions.find { |item| item.dig("attributes", "appStoreState") == "PREPARE_FOR_SUBMISSION" } || versions.first
raise "App Store version #{version_string} was not found" unless version
version_id = version.fetch("id")

localizations = client.get_all(
  "/appStoreVersions/#{version_id}/appStoreVersionLocalizations?fields[appStoreVersionLocalizations]=locale&limit=200"
)
localization = localizations.find { |item| item.dig("attributes", "locale") == "en-US" }
raise "en-US App Store version localization was not found" unless localization
localization_id = localization.fetch("id")

sets = client.get_all(
  "/appStoreVersionLocalizations/#{localization_id}/appScreenshotSets?filter[screenshotDisplayType]=APP_IPHONE_67&fields[appScreenshotSets]=screenshotDisplayType&limit=200"
)
screenshot_set = sets.first
unless screenshot_set
  screenshot_set = client.post(
    "/appScreenshotSets",
    data: {
      type: "appScreenshotSets",
      attributes: { screenshotDisplayType: "APP_IPHONE_67" },
      relationships: {
        appStoreVersionLocalization: {
          data: { type: "appStoreVersionLocalizations", id: localization_id }
        }
      }
    }
  ).fetch("data")
  puts "Created APP_IPHONE_67 screenshot set for en-US"
end
screenshot_set_id = screenshot_set.fetch("id")

existing = client.get_all(
  "/appScreenshotSets/#{screenshot_set_id}/appScreenshots?fields[appScreenshots]=fileName,sourceFileChecksum,assetDeliveryState&limit=200"
)
existing_by_name = existing.to_h { |item| [item.dig("attributes", "fileName"), item] }
unknown = existing_by_name.keys - screenshots.map { |path| File.basename(path) }
raise "Unexpected existing screenshots in APP_IPHONE_67 set: #{unknown.join(', ')}" unless unknown.empty?

ordered_resources = screenshots.map do |path|
  filename = File.basename(path)
  current = existing_by_name[filename]
  checksum = Digest::MD5.file(path).hexdigest
  if current && current.dig("attributes", "sourceFileChecksum") == checksum && asset_state(current) == "COMPLETE"
    puts "Verified existing public screenshot #{filename}"
    current
  elsif current
    raise "Existing screenshot #{filename} is incomplete or differs; refusing destructive replacement"
  else
    puts "Uploading public screenshot #{filename}"
    upload_asset(
      client: client,
      resource_type: "appScreenshots",
      relationship_name: "appScreenshotSet",
      relationship_type: "appScreenshotSets",
      relationship_id: screenshot_set_id,
      path: path
    )
  end
end

client.patch(
  "/appScreenshotSets/#{screenshot_set_id}/relationships/appScreenshots",
  data: ordered_resources.map { |resource| { type: "appScreenshots", id: resource.fetch("id") } }
)
puts "Verified and ordered 8 en-US APP_IPHONE_67 screenshots."

subscriptions = client.get_all(
  "/subscriptionGroups/22318147/subscriptions?fields[subscriptions]=name,productId,state&limit=200"
)
subscriptions_by_product = subscriptions.to_h { |item| [item.dig("attributes", "productId"), item] }
missing_products = expected_products - subscriptions_by_product.keys
raise "Missing subscriptions: #{missing_products.join(', ')}" unless missing_products.empty?

expected_products.each do |product_id|
  subscription = subscriptions_by_product.fetch(product_id)
  subscription_id = subscription.fetch("id")
  current_document = client.get(
    "/subscriptions/#{subscription_id}/appStoreReviewScreenshot?fields[subscriptionAppStoreReviewScreenshots]=fileName,sourceFileChecksum,assetDeliveryState",
    allow_not_found: true
  )
  current = current_document && current_document["data"]
  checksum = Digest::MD5.file(subscription_screenshot).hexdigest
  if current && current.dig("attributes", "sourceFileChecksum") == checksum && asset_state(current) == "COMPLETE"
    puts "Verified existing review screenshot for #{product_id}"
    next
  end
  raise "Existing review screenshot for #{product_id} differs; refusing destructive replacement" if current

  puts "Uploading private review screenshot for #{product_id}"
  upload_asset(
    client: client,
    resource_type: "subscriptionAppStoreReviewScreenshots",
    relationship_name: "subscription",
    relationship_type: "subscriptions",
    relationship_id: subscription_id,
    path: subscription_screenshot
  )
end

puts "Tarot Deck public screenshots and all seven private subscription review screenshots are COMPLETE."
