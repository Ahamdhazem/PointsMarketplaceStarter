//
//  WalletData.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 15/10/2026.
//

//
//"id": 535,
//"name": "Transfer_wallet",
//"code": "transfer_wallet",
//"balance": 181.0,
//"currency": "JOD",
//"color": "#00A63E",
//"selected": true
//},

import Foundation
//let category : String!
//let typeContent : String!
//let imageName : String!
//
//init(_ category: String,_ typeContent: String , _ imageName : String) {
//    self.category = category
//    self.typeContent = typeContent
//    self.imageName = imageName
//}
class WalletData:Decodable{
    
    let id : Int!
    let name:String!
    let code:String!
    let balance:String!
    let currency:String!
    let color:String!
    let selected:Bool!
    
    init(_ id :Int,_ name:String,_ code :String,_ balance:String,_ currency : String,_ color:String,_ selected:Bool) {
        self.id = id
        self.name = name
        self.code = code
        self.balance = balance
        self.currency = currency
        self.color = color
        self.selected = selected
    
    }
}
