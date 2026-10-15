import Foundation
import RxSwift

/// Supplied GET infrastructure. UI, eligibility and POST conversion remain trainee work.
final class ConversionConfigAPI {
    typealias Transport = (URLRequest) async throws -> (Data, HTTPURLResponse)
    private let authorization: () -> Single<String>
    private let transport: Transport
    private let apiKey: String

    init(apiKey: String = APIConfiguration.apiKey,
         authorization: @escaping () -> Single<String> = { AssessmentAuthentication.shared.authorizationHeader() },
         transport: @escaping Transport = { request in
             let (data, response) = try await URLSession.shared.data(for: request)
             guard let response = response as? HTTPURLResponse else { throw ConfigurationError.invalidResponse }
             return (data, response)
         }) {
        self.apiKey = apiKey
        self.authorization = authorization
        self.transport = transport
    }

    func fetchConfiguration() -> Single<ConversionConfiguration> {
        guard !apiKey.isEmpty else { return .error(ConfigurationError.rejected("Missing API configuration.")) }
        // No GET is constructed or sent until token acquisition completes successfully.
        return authorization().flatMap { [self] header in
            guard header.hasPrefix("Bearer "), !header.dropFirst(7).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .error(ConfigurationError.rejected("Authorization returned an empty token."))
            }
            var request = URLRequest(url: APIConfiguration.baseURL.appendingPathComponent("ConversionConfig"))
            request.httpMethod = "GET"
            request.timeoutInterval = 30
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("en", forHTTPHeaderField: "Accept-Language")
            request.setValue(apiKey, forHTTPHeaderField: "api-key")
            request.setValue(header, forHTTPHeaderField: "Authorization")
            return Single.create { observer in
                let task = Task {
                    do {
                        let (data, response) = try await transport(request)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let envelope = try? decoder.decode(ConfigurationEnvelope.self, from: data)
                        guard (200..<300).contains(response.statusCode) else {
                            throw ConfigurationError.rejected(envelope?.usefulMessage ?? "Request failed (HTTP \(response.statusCode)).")
                        }
                        guard let envelope else { throw ConfigurationError.invalidResponse }
                        guard envelope.statusCode.lowercased() == "success", let configuration = envelope.data else {
                            throw ConfigurationError.rejected(envelope.usefulMessage ?? "Unable to load conversion configuration.")
                        }
                        guard configuration.isValid else { throw ConfigurationError.invalidResponse }
                        guard !Task.isCancelled else { return }
                        observer(.success(configuration))
                    } catch {
                        guard !Task.isCancelled else { return }
                        observer(.failure(error))
                    }
                }
                return Disposables.create { task.cancel() }
            }
        }.observe(on: MainScheduler.instance)
    }

    enum ConfigurationError: LocalizedError {
        case invalidResponse
        case rejected(String)
        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "ConversionConfig returned an invalid response. Please retry."
            case .rejected(let message): return message
            }
        }
    }
}

private struct ConfigurationEnvelope: Decodable {
    let statusCode: String
    let data: ConversionConfiguration?
    let message: String?
    let error: ConfigurationAPIError?
    var usefulMessage: String? {
        [error?.message, message, error?.title].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }
}
private struct ConfigurationAPIError: Decodable { let title: String?; let message: String? }

struct ConversionConfiguration: Decodable {
    let enabled: Bool
    let pointsPerUnit: Double
    let minPoints: Int
    let monthlyCap: Int
    let settlementDays: Int
    let minTierId: Int
    let minTierName: String
    let currency: String
    let rateLabel: String
    let pointsBalance: Int
    let tierRank: Int
    let meetsMinTier: Bool
    let meetsMinBalance: Bool
    let monthlyUsed: Int
    let monthlyRemaining: Int
    let canConvert: Bool
    let maxConvertiblePoints: Int
    let estimatedAmountForMax: Double
    let wallets: [Wallet]
    let options: [Option]

    struct Wallet: Decodable {
        let id: Int
        let name: String
        let code: String
        let balance: Double
        let currency: String
        let color: String?
        let selected: Bool
    }
    struct Option: Decodable {
        let id: Int
        let name: String
        let sequence: Int
        let points: Int
        let currencyAmount: Double
        let currency: String
        let convertible: Bool
        let pointsNeeded: Int
        let confirmationTitle: String?
        let confirmationMessage: String?
    }
    fileprivate var isValid: Bool {
        pointsBalance >= 0 && pointsPerUnit.isFinite && pointsPerUnit > 0 && minPoints >= 0
            && maxConvertiblePoints >= 0 && estimatedAmountForMax.isFinite
            && wallets.allSatisfy { $0.id > 0 && $0.balance.isFinite }
            && options.allSatisfy { $0.id > 0 && $0.points > 0 && $0.currencyAmount.isFinite && $0.currencyAmount >= 0 }
            && Set(wallets.map(\.id)).count == wallets.count && Set(options.map(\.id)).count == options.count
    }
}
