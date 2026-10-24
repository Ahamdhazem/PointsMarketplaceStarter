//
//  RedemptionRequest.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 24/10/2026.
//


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
    
    struct RedemptionResponse: Decodable {
        let statusCode: String
        let sales_point_trx_id: String
        let message: String
        let data: RedemptionData
        let error: RedemptionError
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
