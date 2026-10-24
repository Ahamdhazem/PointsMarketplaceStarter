//
//  RedeemCell.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 23/10/2026.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class RedeemCell: UITableViewCell {
    
    @IBOutlet var redeemImage: UIImageView!
    @IBOutlet var redeemTaype: UILabel!
    @IBOutlet var points: UILabel!
    @IBOutlet var claimable: UILabel!
    @IBOutlet var checkBoxButton: UIButton!
    @IBOutlet var minesButton: UIButton!
    @IBOutlet var quntityButton: UIButton!
    @IBOutlet var addbutton: UIButton!
    @IBOutlet var checkBoxView: UIView!
    @IBOutlet var icon: UIImageView!
    
    @IBOutlet var addQuntityView: UIView!
    let quntity = BehaviorRelay<Int>(value:0)
    let isChecked = BehaviorRelay<Bool>(value:false)
    let disposeBag = DisposeBag()
    let cellData = BehaviorRelay<RedemptionItem?>(value: nil)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonsBinding()
    

        self.checkBoxButton.setImage(
            UIImage(named: "check_box_on"),
            for: .selected
        )
        self.checkBoxButton.setImage(
            UIImage(named: "check_box_off"),
            for: .normal
        )
        bindingcellData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //func
    func buttonsBinding(){
        quntity
            .map{String($0)}
            .bind(to: quntityButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        addbutton.rx.tap.subscribe(
            onNext: { [weak self] in
                guard let self = self else {return }
                guard let cellData = cellData.value else {return}
                if(self.quntity.value < cellData.max_quantity){
                self.quntity.accept(self.quntity.value + 1)}
            }
        ).disposed(by: disposeBag)
        
        
        minesButton.rx.tap.subscribe(
            onNext: { [weak self] in
                guard let self = self else {return }
                if self.quntity.value >= 1{
                self.quntity.accept(self.quntity.value - 1)}
            }
        ).disposed(by: disposeBag)
        
        
    

    let onContentViewTaped = self.contentView.rx
            .tapGesture()
            .when(.recognized)
            .map{_ in ()}

        
        let onCheckBoxTaped = checkBoxButton.rx.tap.map{_ in ()}
        
        Observable.merge(onCheckBoxTaped,onContentViewTaped)
            .subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.isChecked.accept(!(self.isChecked.value))
                    self.checkBoxButton.isSelected = self.isChecked.value
                    let imageName = self.isChecked.value
                        ? "check_box_on"
                        : "check_box_off"
                    self.checkBoxButton.setImage(
                        UIImage(named: imageName),
                        for: .normal
                    )
                }
            ).disposed(by: disposeBag)
    }
    func bindingcellData(){
        
        guard let cellData = cellData.value else {return}
        
        redeemTaype.text = cellData.name
        points.text = String(cellData.points_cost)
        claimable.text = cellData.claimable ? "claimable" : "unclaimable"
        

//        "Vouchers",
//        "Gift",
//        "Mobile Data Bundle"
        switch(cellData.category){
        case "Vouchers": icon.image = UIImage(named:"voucher_icon" )
        case "Gift": icon.image = UIImage(named:"mobile_phone_icon" )
        case "Mobile Data Bundle": icon.image = UIImage(named: "data_bundle_icon")
        default:
            print("")
        }
        
        if(cellData.max_quantity <= 1){
            addQuntityView.isHidden = true
        }

        }
    }

