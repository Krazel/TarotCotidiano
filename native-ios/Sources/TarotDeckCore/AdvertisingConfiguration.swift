import Foundation

/// Fail-closed separation of Google's sample inventory and the Studio publisher.
public enum AdvertisingConfiguration {
    public static let sampleApplicationID = "ca-app-pub-3940256099942544~1458002511"
    public static let sampleBannerID = "ca-app-pub-3940256099942544/2435281174"

    public static func bannerID(mode: String?, applicationID: String?, unitID: String?,
                                allowsProduction: Bool) -> String? {
        if !allowsProduction {
            guard mode == "test-only", applicationID == sampleApplicationID,
                  unitID == sampleBannerID else { return nil }
            return sampleBannerID
        }
        guard mode == "production", let applicationID, let unitID,
              applicationID.range(of: "^ca-app-pub-3425091654264901~[0-9]{10}$", options: .regularExpression) != nil,
              unitID.range(of: "^ca-app-pub-3425091654264901/[0-9]{10}$", options: .regularExpression) != nil
        else { return nil }
        return unitID
    }
}
