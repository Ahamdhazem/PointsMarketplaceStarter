//
//  ConversionCell.swift
//  PointsMarketplaceStarter
//
//  Created by LP Mackbook on 15/10/2026.
//

import UIKit
//
//name    Title label, e.g. “Bronze Pack”
//points    “1,000 pts”
//currencyAmount + currency    “≈ 10.00 USD”
//convertible / pointsNeeded    If false, dim the cell and show “Need 250 more pts”
//selected state    Radio or checkmark image

class ConversionCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var covertibleLabel: UILabel!
    @IBOutlet var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization codeselectedBackground,
        self.selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let color: UIColor = selected ? .systemGreen : .systemBackground

          if animated {
              UIView.animate(withDuration: 0.25) {
                  self.contentView.backgroundColor = color
              }
          } else {
              contentView.backgroundColor = color
          }
      }
    
    
    func configer(_ name:String,_ points : Int , _ pointsNeded : Int){
        nameLabel.text = name
        pointsLabel.text = String(points)
        covertibleLabel.text =  points >= pointsNeded ? "covertible" : "you need \(pointsNeded-points) "
    }
    
}
