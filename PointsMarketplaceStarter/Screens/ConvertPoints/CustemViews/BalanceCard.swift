//  BalanceCard.swift
import UIKit
import RxSwift
@IBDesignable
class BalanceCard: UIView {

    @IBOutlet var mainView: UIView!
    
    @IBOutlet var convertButton: UIButton!
    
    
    var onConvertTaped : (() -> Void)?
    let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func bindConvertButton(){
        convertButton.rx.tap.subscribe(
            onNext: { [weak self] in

                self?.onConvertTaped?()
            }
        ).disposed(by:disposeBag)
    }
    

    
     func commonInit() {

        let bundle = Bundle(for: BalanceCard.self)
        bundle.loadNibNamed("BalanceCard", owner: self, options: nil)

        guard let mainView = mainView else { return }
        mainView.frame = bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(mainView)
         bindConvertButton()
    }
}
