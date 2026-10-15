import Foundation

/// Configuration only. ConversionConfig GET is supplied; POST conversion is trainee work.
/// AssessmentAuthentication supplies token acquisition; authentication is outside the assessment.
enum APIConfiguration {
    static let baseURL = URL(
        string: "https://devapi-salespoint.leading-point.org/api/Core/v3.0/loyalty"
    )!

    static let tokenObtainURL = URL(
        string: "https://devapi-salespoint.leading-point.org/api/Core/v3.0/auth/token/obtain"
    )!

    static var username: String { configuredValue("AssessmentAuthUsername") }
    static var password: String { configuredValue("AssessmentAuthPassword") }
    static var deviceToken: String { configuredValue("AssessmentAuthDeviceToken") }

    private static func configuredValue(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }

    static var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "AssessmentAPIKey") as? String ?? ""
    }

    /// Raw access token; prepend "Bearer " in the Authorization request header.
    static var bearerToken: String {
        Bundle.main.object(forInfoDictionaryKey: "AssessmentBearerToken") as? String ?? ""
    }
}
