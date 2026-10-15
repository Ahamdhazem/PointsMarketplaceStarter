//
//  WalletCell.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 15/10/2026.
//

import UIKit
import RxSwift
import RxCocoa
class WalletCell: UITableViewCell {

    @IBOutlet var mainView: UIView!
    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var radioButton: UIButton!
    let disposeBage = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func radioButtonSub(){
        radioButton.rx.tap.subscribe(onNext: {[weak self] in
       
//            self.radioButton.setImage(
//                   UIImage(systemName: ""),
//                   for: .normal
//               )
            
        }).disposed(by: disposeBage)
    }

    func configer(_ titel:String,_  balance:String , _ coloer:String){
        self.titelLabel.text = titel
        self.balanceLabel.text = balance
//              mainView.backgroundColor = 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
