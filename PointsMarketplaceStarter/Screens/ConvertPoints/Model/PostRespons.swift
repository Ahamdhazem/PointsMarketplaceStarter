//
//  PostRespons.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 19/10/2026.
//

import Foundation
class PostRespons:Decodable{
    
    let statusCode :String
    let sales_point_trx_id : String
    let message :String
    let data : PostData
    let error :  PostResponsError

    }
    
    struct PostData:Decodable {
        let redemption_id : Int
        let name: String
        let state : String
        let state_color : String
        let points_spent : Int
        let currency_amount : Float
        let currency: String
        let points_balance:Int
        let option_id: Int
        let wallet_id : Int
        let wallet_name : String
        let settlement_days : Int
    }

struct PostResponsError : Decodable {
        let code : String
        let title : String
        let message : String
        let detail:String
        let extra_data: [String: String]?
    }
