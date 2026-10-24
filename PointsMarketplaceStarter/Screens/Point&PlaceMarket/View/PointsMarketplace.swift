//
//  PointsMarketplace.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 22/10/2026.
//

import UIKit
import RxSwift
import RxRelay

class PointsMarketplace: UIViewController {

    @IBOutlet var redeemTableView: UITableView!
    @IBOutlet var balanceCard: BalanceCard!
    @IBOutlet var reddemButton: UIButton!
    let conversionConfigAPI =  ConversionConfigAPI()
//    let SelectedItem = BehaviorRelay<>
    let redeemsData = BehaviorRelay<[RedemptionItem]?>(value:[
        RedemptionItem(
                id: 1,
                name: "Gift Card",
                code: "GC10",
                description: "$10 Gift Card",
                category: "Rewards",
                icon: "gift",
                points_cost: 1000,
                scheme_id: 1,
                min_tier_id: 1,
                min_tier_name: "Bronze",
                redemption_type: "digital",
                requires_delivery: false,
                stock_available: 50,
                in_stock: true,
                max_quantity: 5,
                max_quantity_label: "Max 5",
                is_eligible: true,
                affordable: true,
                claimable: true,
                points_needed: 0,
                status_label: "Available",
                confirmation_title: "Confirm",
                confirmation_message: "Are you sure?"
            ),
        RedemptionItem(
                id: 1,
                name: "Gift Card",
                code: "GC10",
                description: "$10 Gift Card",
                category: "Rewards",
                icon: "gift",
                points_cost: 1000,
                scheme_id: 1,
                min_tier_id: 1,
                min_tier_name: "Bronze",
                redemption_type: "digital",
                requires_delivery: false,
                stock_available: 50,
                in_stock: true,
                max_quantity: 5,
                max_quantity_label: "Max 5",
                is_eligible: true,
                affordable: true,
                claimable: true,
                points_needed: 0,
                status_label: "Available",
                confirmation_title: "Confirm",
                confirmation_message: "Are you sure?"
            ),
        RedemptionItem(
                id: 1,
                name: "Gift Card",
                code: "GC10",
                description: "$10 Gift Card",
                category: "Rewards",
                icon: "gift",
                points_cost: 1000,
                scheme_id: 1,
                min_tier_id: 1,
                min_tier_name: "Bronze",
                redemption_type: "digital",
                requires_delivery: false,
                stock_available: 50,
                in_stock: true,
                max_quantity: 5,
                max_quantity_label: "Max 5",
                is_eligible: true,
                affordable: true,
                claimable: true,
                points_needed: 0,
                status_label: "Available",
                confirmation_title: "Confirm",
                confirmation_message: "Are you sure?"
            )
    ])
    var redemptionCatalogRespons = BehaviorRelay<RedemptionCatalog?>(value: nil)
    let disposbage = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Poin & Marketplace"
        
        
        
        reddemButton.rx.tap.subscribe(
            onNext:{ print("")}
        ).disposed(by: disposbage)
        
        conversionConfigAPI.fetcRedemptionCatalog().subscribe(
            onSuccess: { [weak self] result in
                self?.redeemsData.accept(result.data.items)
                print(self?.redeemsData.value)
            },
            onFailure: { error in
                  print("error",error)
              }
        ).disposed(by: disposbage)
        
        
        tableViewCongfier()
        
        balanceCard.onConvertTaped = { [weak self] in
            guard let self = self else { return }

            let vc = ConvertPointsViewController()
            if let nav = self.navigationController {

                   nav.pushViewController(vc, animated: true)
               } else {return}
        }
    }
    
    
    func tableViewCongfier(){
        cellRejster()
        tableViewBinding()
    }
    
    func cellRejster(){
        let nib = UINib(nibName: "RedeemCell", bundle: nil)
        redeemTableView.register(nib, forCellReuseIdentifier: "RedeemCell")
    }

  func tableViewBinding(){
      

        redeemsData
        .compactMap { $0 }
        .asDriver(onErrorRecover: { error in
            print(error)
            return .empty()          // or .just([])
        })
       .drive(redeemTableView.rx.items(
        cellIdentifier: "RedeemCell",
        cellType:RedeemCell.self
      )){
          index,redeam, cell in
          cell.cellData.accept(redeam)
          cell.bindingcellData()
      }
      
      redeemTableView.rx.modelSelected(RedemptionItem.self).subscribe(
        onNext: {print($0)}
      )
      
      
  }

    
}
