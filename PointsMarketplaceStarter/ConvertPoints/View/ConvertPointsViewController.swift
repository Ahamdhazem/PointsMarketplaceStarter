import UIKit
import RxSwift
import RxCocoa
import Alamofire
/// Trainee entry point. App setup, assets and authentication are supplied.
final class ConvertPointsViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var conversionAPI = ConversionConfigAPI()
    var configuration = BehaviorRelay<ConversionConfiguration?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let loadError = BehaviorRelay<String?>(value: nil)
   
    @IBOutlet var walletTableView: UITableView!
    @IBOutlet var conversionTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Convert Points"
        loadConversionConfig()
        cellRejestration()
        cellBinding()

        // TODO: Build the screen and reusable wallet/option cells using XIBs and Auto Layout.
        // GET and its models are supplied in ConversionConfigAPI.swift.
        // TODO: Implement POST ConvertPoints; see Documentation/API.md.
        // Use AssessmentAuthentication.shared.authorizationHeader() before each request.
        // TODO: Model loading, eligibility, single selections and submitting state with RxSwift.
        // TODO: Confirm, submit once, show the returned receipt, then reload configuration.
        // TODO: Handle errors/empty data and complete the README acceptance scenarios.
    }
    func cellRejestration() {
       let nib1 = UINib(nibName: "WalletCell", bundle: nil)
        walletTableView.register(nib1, forCellReuseIdentifier: "WalletCell")
        
        let nib2 = UINib(nibName: "ConversionCell", bundle: nil)
        conversionTableView.register(nib2, forCellReuseIdentifier: "ConversionCell")
   }
   
   func cellBinding() {
     // //  let guard  configuration = configuration else {return }
       
//       configuration
//                    .asObservable()
//                    .bind(to: walletTableView.rx.items(
//                        cellIdentifier: "WalletCell",
//                        cellType: WalletCell.self
//                    )) { index, item, cell in
//                        cell.configer(item.Wallet.name, item.Wallet.name,item.Wallet.name)
//                        
//                        
//                    }
//                    .disposed(by: disposeBag)
       }
    /// Also reusable for Retry and the post-conversion refresh.
    func loadConversionConfig() {
        guard !isLoading.value else { return }
        isLoading.accept(true)
        loadError.accept(nil)
        conversionAPI.fetchConfiguration().subscribe(onSuccess: { [weak self] result in
            self?.configuration.accept(result)
            self?.isLoading.accept(false)
        }, onFailure: { [weak self] error in
            self?.loadError.accept(error.localizedDescription)
            self?.isLoading.accept(false)
        }).disposed(by: disposeBag)
    }
    
    
    func ConvertConversion(){


        let parameters = [""]

        let url = "https:/post"

       

    }
}
