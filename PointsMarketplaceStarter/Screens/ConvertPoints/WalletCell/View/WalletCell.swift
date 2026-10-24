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


    @IBOutlet var containerView: UIView!
    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var radioButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!
    let disposeBage = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        radioButton.setImage(UIImage(named: "radio_button_off_white"), for: .normal)
        radioButton.setImage(UIImage(named: "radio_button_on_white"), for: .selected)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        radioButton.isSelected = selected            // image follows the default selection
     
    }

    func configer(_ titel:String,_  balance:String , _ color:String){
        self.titelLabel.text = titel
        self.balanceLabel.text = balance
        setBackGroundImage(color)
    }
    
    func setBackGroundImage(_ color:String){
        let imageName: String
            
            switch color {
            case "#00A63E":
                imageName = "voucher_bg_icon"
            case "#065fb1":
                imageName = "topup_icon"
            case "#4ddb50":
                imageName = "wallet_type_icon"
            default:
                imageName = "topup_icon"
            }
                backgroundImage.image = UIImage(named: imageName)
    }
    
    
}



