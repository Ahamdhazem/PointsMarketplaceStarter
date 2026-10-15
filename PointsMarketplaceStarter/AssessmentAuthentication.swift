import Foundation
import RxSwift

/// Supplied infrastructure, not trainee work. Does not call conversion endpoints.
final class AssessmentAuthentication {
    static let shared = AssessmentAuthentication()

    struct LoginValues {
        let username: String
        let password: String
        let deviceToken: String
    }

    typealias Transport = (URLRequest) async throws -> (Data, HTTPURLResponse)
    private let provider: TokenProvider

    init(
        providedToken: String = APIConfiguration.bearerToken,
        apiKey: String = APIConfiguration.apiKey,
        login: LoginValues = LoginValues(
            username: APIConfiguration.username,
            password: APIConfiguration.password,
            deviceToken: APIConfiguration.deviceToken
        ),
        transport: @escaping Transport = { request in
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw AuthenticationError.invalidResponse
            }
            return (data, response)
        }
    ) {
        provider = TokenProvider(
            providedToken: providedToken, apiKey: apiKey, login: login, transport: transport
        )
    }

    /// Emits the complete Authorization header value, including "Bearer ".
    /// Call before constructing a conversion request; delivery is on the main thread.
    func authorizationHeader() -> Single<String> {
        Single.create { [self] observer in
            let task = Task {
                do {
                    let header = try await obtainAuthorizationHeader()
                    guard !Task.isCancelled else { return }
                    observer(.success(header))
                } catch {
                    guard !Task.isCancelled else { return }
                    observer(.failure(error))
                }
            }
            return Disposables.create { task.cancel() }
        }
        .observe(on: MainScheduler.instance)
    }

    // Also permits focused async verification of the supplied infrastructure.
    func obtainAuthorizationHeader() async throws -> String {
        "Bearer \(try await provider.token())"
    }

    enum AuthenticationError: LocalizedError {
        case missingConfiguration
        case invalidResponse
        case rejected(String)

        var errorDescription: String? {
            switch self {
            case .missingConfiguration:
                return "Ask your reviewer for a token or configure the supplied API-ready login values."
            case .invalidResponse:
                return "Token acquisition returned an invalid response or an empty/expired token."
            case .rejected(let message):
                return message
            }
        }
    }

    private actor TokenProvider {
        private let providedToken: String
        private let apiKey: String
        private let login: LoginValues
        private let transport: Transport
        private var cached: Token?
        private var inFlight: Task<Token, Error>?

        init(providedToken: String, apiKey: String, login: LoginValues,
             transport: @escaping Transport) {
            self.providedToken = providedToken.trimmingCharacters(in: .whitespacesAndNewlines)
            self.apiKey = apiKey
            self.login = login
            self.transport = transport
        }

        func token() async throws -> String {
            // A reviewer-supplied token takes precedence over automatic acquisition.
            if usable(providedToken) { return providedToken }
            if let cached, cached.expiresAt.map({ $0 > Date().addingTimeInterval(30) }) ?? true {
                return cached.value
            }
            // All callers await one acquisition; only its creator writes the cache.
            if let inFlight { return try await inFlight.value.value }
            guard usable(apiKey), usable(login.username), usable(login.password),
                  usable(login.deviceToken) else {
                throw AuthenticationError.missingConfiguration
            }

            var request = URLRequest(url: APIConfiguration.tokenObtainURL)
            request.httpMethod = "POST"
            request.timeoutInterval = 30
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("en", forHTTPHeaderField: "Accept-Language")
            request.setValue(apiKey, forHTTPHeaderField: "api-key")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(LoginBody(
                device_token: login.deviceToken, password: login.password,
                username: login.username, query_params: [:]
            ))
            let transport = self.transport
            let task = Task<Token, Error> {
                let (data, response) = try await transport(request)
                let envelope = try? JSONDecoder().decode(Envelope.self, from: data)
                guard (200..<300).contains(response.statusCode) else {
                    throw AuthenticationError.rejected(
                        envelope?.failureMessage ?? "Token acquisition failed (HTTP \(response.statusCode))."
                    )
                }
                guard let envelope else { throw AuthenticationError.invalidResponse }
                guard envelope.statusCode == "success" else {
                    throw AuthenticationError.rejected(
                        envelope.failureMessage ?? "Token acquisition was rejected."
                    )
                }
                guard let raw = envelope.data?.access_token,
                      !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw AuthenticationError.invalidResponse
                }
                let expiry = envelope.data?.access_token_expiry_time.map {
                    Date(timeIntervalSince1970: $0)
                }
                if let expiry, expiry <= Date() { throw AuthenticationError.invalidResponse }
                return Token(value: raw.trimmingCharacters(in: .whitespacesAndNewlines), expiresAt: expiry)
            }
            inFlight = task
            do {
                let token = try await task.value
                cached = token
                inFlight = nil
                return token.value
            } catch {
                inFlight = nil
                throw error
            }
        }

        private func usable(_ value: String) -> Bool {
            let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return !value.isEmpty && !value.hasPrefix("REPLACE_WITH_")
        }
    }

    private struct Token {
        let value: String
        let expiresAt: Date?
    }

    private struct LoginBody: Encodable {
        let device_token: String
        let password: String
        let username: String
        let query_params: [String: String]
    }

    private struct Envelope: Decodable {
        let statusCode: String
        let message: String?
        let data: TokenData?
        let error: ErrorData?

        var failureMessage: String? {
            [error?.message, message].compactMap { $0 }
                .first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
    }

    private struct TokenData: Decodable {
        let access_token: String?
        let access_token_expiry_time: Double?
    }

    private struct ErrorData: Decodable {
        let message: String?
    }
}
