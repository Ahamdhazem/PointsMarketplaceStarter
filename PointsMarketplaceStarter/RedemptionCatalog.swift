//
//  RedemptionCatalog.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 24/10/2026.
//


    class RedemptionCatalog : Decodable{
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
