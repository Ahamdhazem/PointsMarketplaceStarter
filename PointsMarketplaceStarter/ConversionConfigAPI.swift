import Foundation
import RxSwift
import Alamofire

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
    
    
    
    func postReadeem()->Single<RedemptionResponse>{
        guard !apiKey.isEmpty else { return .error(ConfigurationError.rejected("Missing API configuration.")) }
        return authorization().flatMap { [self] header in
            guard header.hasPrefix("Bearer "), !header.dropFirst(7).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .error(ConfigurationError.rejected("Authorization returned an empty token."))
            }
         return   Single.create{ observer in
                let headers:HTTPHeaders = [
                    "accept" : "application/json" ,
                    "Accept-Language":"en",
                    "api-key": apiKey,
                    "Authorization": header,
                    "Content-Type": "application/json"
                ]
                let body = RedemptionRequest(
                    items: [
                        RedemptionRequestItem(
                            item_id: 12,
                            quantity: 1,
                            idempotency_key: ""
                        )
                    ],
                    phone_number: "966565432768",
                    delivery_address: "Amman",
                    delivery_note: ""
                )
                
                let request = AF.request(
                    "https://devapi-salespoint.leading-point.org/api/Core/v3.0/loyalty/Redeem",
                    method: .post,
                    parameters:body,
                    encoder:JSONParameterEncoder(),
                    headers:headers
                ).validate()
                    .responseDecodable(of:RedemptionResponse.self){
                        response in
                        switch response.result{
                        case .success(let data): observer(.success(data))
                        case .failure(let error): observer(.failure(error))
                        }
                    }
                
                return Disposables.create {
                    request.cancel()
                }
            }
            
        }}
        
        func fetcRedemptionCatalog() ->Single<RedemptionCatalog>  {
            
            guard !apiKey.isEmpty else { return .error(ConfigurationError.rejected("Missing API configuration.")) }
            return authorization().flatMap { [self] header in
                guard header.hasPrefix("Bearer "), !header.dropFirst(7).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .error(ConfigurationError.rejected("Authorization returned an empty token."))
                }
                
                return Single.create{ observer in
                    let headers: HTTPHeaders = [
                        "accept" : "application/json" ,
                        "Accept-Language":"en",
                        "api-key": apiKey,
                        "Authorization": header,
                        "Content-Type": "application/json"
                    ]
                    
                    let request = AF.request(
                        "https://devapi-salespoint.leading-point.org/api/Core/v3.0/loyalty/RedemptionCatalog",
                        method: .get,
                        headers: headers
                    ).validate()
                        .responseDecodable(of:RedemptionCatalog.self){ response in
                            switch(response.result){
                                
                            case .success(let data): observer(.success(data))
                            case .failure(let data): observer(.failure(data))
                                
                            }
                            
                        }
                    return Disposables.create{
                        request.cancel()
                    }
                }
                
            }
            
            
        }
        
        func PostNewConversion()->Single<PostRespons>{
            guard !apiKey.isEmpty else { return .error(ConfigurationError.rejected("Missing API configuration.")) }
            // No GET is constructed or sent until token acquisition completes successfully.
            return authorization().flatMap { [self] header in
                guard header.hasPrefix("Bearer "), !header.dropFirst(7).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .error(ConfigurationError.rejected("Authorization returned an empty token."))
                }
                return Single.create{ observer in
                    
                    struct ConvertPointsRequest: Encodable {
                        let optionId: Int
                        let walletId: Int
                        let idempotencyKey: String
                    }
                    
                    let body = ConvertPointsRequest(optionId: 3,
                                                    walletId: 537,
                                                    idempotencyKey: UUID().uuidString)
                    let encoder = JSONParameterEncoder()
                    encoder.encoder.keyEncodingStrategy = .convertToSnakeCase
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let headers: HTTPHeaders = [
                        "accept" : "application/json" ,
                        "Accept-Language":"en",
                        "api-key": apiKey,
                        "Authorization": header,
                        "Content-Type": "application/json"
                        
                    ]
                    let request = AF.request(
                        APIConfiguration.baseURL.appendingPathComponent("ConvertPoints"),
                        method: .post,
                        parameters: body,
                        encoder: encoder,
                        headers: headers
                    ).validate()
                        .responseDecodable(of:PostRespons.self){respons in
                            switch respons.result{
                            case .success(let data):
                                print("success")
                                return observer(.success(data))
                            case .failure(let error): observer(.failure(error))
                                
                            }
                        }
                    
                    return Disposables.create{
                        request.cancel()
                    }
                }
            }
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
    

// get all Redmetion get rquest
    struct RedemptionCatalog : Decodable{
        let statusCode : String
        let sales_point_trx_id : String
        let message: String
        let data : RedemptionData
        let error:RedemptionError
    }
    
    
    struct RedemptionData: Decodable{
        let points_balance : Int
        let lifetime_earned: Int
        let lifetime_spent: Int
        let convert_enabled: Bool
        let can_convert: Bool
        let categories: [String]
        let items: [RedemptionItem]
    }
    
    struct RedemptionError : Decodable{
        let code : String
        let title : String
        let message : String
        let detail : String
        let extra_data : [String:String]
    }
    
    
    struct RedemptionItem : Decodable{
        let id: Int
        let name : String
        let code : String
        let description :String
        let category : String
        let icon : String
        let points_cost : Int
        let scheme_id : Int
        let min_tier_id : Int
        let min_tier_name : String
        let redemption_type: String
        let requires_delivery: Bool
        let stock_available :Int
        let in_stock : Bool
        let max_quantity : Int
        let max_quantity_label: String
        let is_eligible : Bool
        let affordable : Bool
        let claimable : Bool
        let points_needed: Int
        let status_label: String
        let confirmation_title:String
        let confirmation_message : String
    }


// Redeem Post Request

//response:
struct RedemptionResponse: Decodable {
    let statusCode: String
    let sales_point_trx_id: String
    let message: String
    let data: RedemptionData
    let error: RedemptionError
}

// Rquest
    struct RedemptionRequest: Encodable {
        let items: [RedemptionRequestItem]
        let phone_number: String
        let delivery_address: String
        let delivery_note: String
    }
    
    struct RedemptionRequestItem: Encodable {
        let item_id: Int
        let quantity: Int
        let idempotency_key: String
    }
    

    
    struct RedemptionREsponseData: Decodable {
        let results: [RedemptionResult]
        let points_balance: Int
        let phone_number: String
        let delivery_address: String
        let delivery_note: String
    }
    
    struct RedemptionResult: Decodable {
        let item_id: Int
        let redemption_id: Int
        let name: String
        let item: String
        let quantity: Int
        let state: String
        let state_color: String
        let points_spent: Int
        let requires_delivery: Bool
        let success: Bool
        let message: String
    }


