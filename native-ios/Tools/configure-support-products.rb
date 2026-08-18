#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "date"
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

  private

  def request(method_class, path, payload = nil)
    uri = URI(absolute_url(path))
    request = method_class.new(uri)
    request["Authorization"] = "Bearer #{token}"
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(payload) if payload
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
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
    raw_signature = sequence.value.map do |integer|
      integer.value.to_s(2).rjust(32, "\0")
    end.join
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

def relationship(resource, name)
  resource.dig("relationships", name, "data")
end

def require_env(name)
  value = ENV[name]
  raise "Missing required environment variable #{name}" if value.nil? || value.empty?

  value
end

manifest_path = ARGV.fetch(0, "store/tarot-subscriptions.v1.json")
manifest = JSON.parse(File.read(manifest_path))
raise "Unexpected subscription manifest schema" unless manifest["schemaVersion"] == 1

client = AppStoreConnectClient.new(
  key_id: require_env("APP_STORE_CONNECT_API_KEY_ID"),
  issuer_id: require_env("APP_STORE_CONNECT_ISSUER_ID"),
  key_path: require_env("APP_STORE_CONNECT_API_KEY_PATH")
)

app_id = manifest.fetch("appAppleID")
group_config = manifest.fetch("subscriptionGroup")
territories = manifest.fetch("territories").sort

app = client.get("/apps/#{app_id}")
bundle_id = app.dig("data", "attributes", "bundleId")
raise "Unexpected App Store Connect bundle ID #{bundle_id.inspect}" unless bundle_id == manifest.fetch("bundleID")

groups = client.get_all("/apps/#{app_id}/subscriptionGroups?fields[subscriptionGroups]=referenceName&limit=200")
group = groups.find { |item| item.dig("attributes", "referenceName") == group_config.fetch("referenceName") }
unless group
  created = client.post(
    "/subscriptionGroups",
    data: {
      type: "subscriptionGroups",
      attributes: { referenceName: group_config.fetch("referenceName") },
      relationships: { app: { data: { type: "apps", id: app_id } } }
    }
  )
  group = created.fetch("data")
  puts "Created subscription group #{group.fetch('id')}"
end
group_id = group.fetch("id")

group_localizations = client.get_all(
  "/subscriptionGroups/#{group_id}/subscriptionGroupLocalizations?limit=200"
)
group_config.fetch("localizations").each do |locale, name|
  existing = group_localizations.find { |item| item.dig("attributes", "locale") == locale }
  if existing
    raise "Subscription group localization #{locale} differs from the manifest" unless existing.dig("attributes", "name") == name
    next
  end

  client.post(
    "/subscriptionGroupLocalizations",
    data: {
      type: "subscriptionGroupLocalizations",
      attributes: { locale: locale, name: name },
      relationships: { subscriptionGroup: { data: { type: "subscriptionGroups", id: group_id } } }
    }
  )
  puts "Created subscription group localization #{locale}"
end

subscriptions = client.get_all(
  "/subscriptionGroups/#{group_id}/subscriptions?fields[subscriptions]=name,productId,subscriptionPeriod,groupLevel,state&limit=200"
)

manifest.fetch("products").each do |product_config|
  product_id = product_config.fetch("productID")
  subscription = subscriptions.find { |item| item.dig("attributes", "productId") == product_id }
  unless subscription
    created = client.post(
      "/subscriptions",
      data: {
        type: "subscriptions",
        attributes: {
          name: product_config.fetch("referenceName"),
          productId: product_id,
          subscriptionPeriod: group_config.fetch("period"),
          familySharable: false,
          groupLevel: group_config.fetch("groupLevel"),
          availableInAllTerritories: false,
          reviewNote: "Optional monthly support. All app features remain free; active entitlement only shows supporter status in Settings."
        },
        relationships: { group: { data: { type: "subscriptionGroups", id: group_id } } }
      }
    )
    subscription = created.fetch("data")
    subscriptions << subscription
    puts "Created subscription #{product_id}"
  end
  subscription_id = subscription.fetch("id")
  attributes = subscription.fetch("attributes")
  unless attributes["name"] == product_config.fetch("referenceName") &&
         attributes["productId"] == product_id &&
         attributes["subscriptionPeriod"] == group_config.fetch("period") &&
         attributes["groupLevel"] == group_config.fetch("groupLevel")
    raise "#{product_id} attributes differ from the approved manifest"
  end

  localizations = client.get_all("/subscriptions/#{subscription_id}/subscriptionLocalizations?limit=200")
  manifest.fetch("productLocalizations").each do |locale, localization|
    existing = localizations.find { |item| item.dig("attributes", "locale") == locale }
    if existing
      unless existing.dig("attributes", "name") == localization.fetch("name") &&
             existing.dig("attributes", "description") == localization.fetch("description")
        raise "#{product_id} localization #{locale} differs from the manifest"
      end
      next
    end

    client.post(
      "/subscriptionLocalizations",
      data: {
        type: "subscriptionLocalizations",
        attributes: {
          locale: locale,
          name: localization.fetch("name"),
          description: localization.fetch("description")
        },
        relationships: { subscription: { data: { type: "subscriptions", id: subscription_id } } }
      }
    )
    puts "Created #{product_id} localization #{locale}"
  end

  availability = client.get(
    "/subscriptions/#{subscription_id}/subscriptionAvailability?include=availableTerritories&limit[availableTerritories]=50",
    allow_not_found: true
  )
  if availability.nil?
    client.post(
      "/subscriptionAvailabilities",
      data: {
        type: "subscriptionAvailabilities",
        attributes: { availableInNewTerritories: false },
        relationships: {
          availableTerritories: {
            data: territories.map { |territory| { type: "territories", id: territory } }
          },
          subscription: { data: { type: "subscriptions", id: subscription_id } }
        }
      }
    )
    puts "Configured #{product_id} availability: #{territories.join(',')}"
  else
    actual = Array(availability["included"]).select { |item| item["type"] == "territories" }.map { |item| item["id"] }.sort
    unless actual == territories && availability.dig("data", "attributes", "availableInNewTerritories") == false
      raise "#{product_id} availability differs from the approved #{territories.join(',')} allowlist"
    end
  end

  desired_price = product_config.fetch("priceEUR").to_f
  price_points = client.get_all(
    "/subscriptions/#{subscription_id}/pricePoints?filter[territory]=ESP&limit=8000"
  )
  base_point = price_points.find do |point|
    (point.dig("attributes", "customerPrice").to_f - desired_price).abs < 0.001
  end
  raise "No exact ESP price point for #{product_id} at #{desired_price}" unless base_point

  point_by_territory = { "ESP" => base_point }
  equalized = client.get_all(
    "/subscriptionPricePoints/#{URI.encode_www_form_component(base_point.fetch('id'))}/equalizations?include=territory&limit=8000"
  )
  equalized.each do |point|
    territory_id = relationship(point, "territory")&.fetch("id", nil)
    point_by_territory[territory_id] = point if territories.include?(territory_id)
  end
  missing_points = territories - point_by_territory.keys
  raise "Missing equalized price points for #{product_id}: #{missing_points.join(',')}" unless missing_points.empty?

  existing_prices = client.get_all(
    "/subscriptions/#{subscription_id}/prices?include=territory,subscriptionPricePoint&limit=200"
  )
  territories.each do |territory_id|
    desired_point_id = point_by_territory.fetch(territory_id).fetch("id")
    existing = existing_prices.find { |price| relationship(price, "territory")&.fetch("id", nil) == territory_id }
    if existing
      existing_point_id = relationship(existing, "subscriptionPricePoint")&.fetch("id", nil)
      raise "#{product_id} already has a different #{territory_id} price" unless existing_point_id == desired_point_id
      next
    end

    client.post(
      "/subscriptionPrices",
      data: {
        type: "subscriptionPrices",
        attributes: {
          startDate: Date.today.iso8601,
          preserveCurrentPrice: false
        },
        relationships: {
          subscription: { data: { type: "subscriptions", id: subscription_id } },
          subscriptionPricePoint: {
            data: { type: "subscriptionPricePoints", id: desired_point_id }
          }
        }
      }
    )
    puts "Configured #{product_id} price for #{territory_id}"
  end
end

puts "Tarot Deck monthly support products are configured idempotently for #{territories.join(', ')}."
