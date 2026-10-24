import UIKit
import RxSwift
import RxCocoa
import Alamofire
/// Trainee entry point. App setup, assets and authentication are supplied.
final class ConvertPointsViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var conversionAPI = ConversionConfigAPI()
    var configuration = BehaviorRelay<ConversionConfiguration?>(value: nil)
    var postRespons = BehaviorRelay<PostRespons?>(value: nil)
    var redemptionCatalogRespons = BehaviorRelay<RedemptionCatalog?>(value: nil)

    let isLoading = BehaviorRelay<Bool>(value: false)
    let loadError = BehaviorRelay<String?>(value: nil)
    @IBOutlet var balanceCard: BalanceCard!
    
    @IBOutlet var walletTableView: UITableView!
    @IBOutlet var conversionTableView: UITableView!
    @IBOutlet var walletTabelViewHightConstraint: NSLayoutConstraint!
    @IBOutlet var conversinTabelViewHightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Convert Points"
        loadConversionConfig()
        cellRejestration()
        walletCellBinding()
        conversionCellBinding()
//        addNewConvertion()
        loadgetRedemptionCatalog()
      
    
        // TODO: Build the screen and reusable wallet/option cells using XIBs and Auto Layout.
        // GET and its models are supplied in ConversionConfigAPI.swift.
        // TODO: Implement POST ConvertPoints; see Documentation/API.md.
        // Use AssessmentAuthentication.shared.authorizationHeader() before each request.
        // TODO: Model loading, eligibility, single selections and submitting state with RxSwift.
        // TODO: Confirm, submit once, show the returned receipt, then reload configuration.
        // TODO: Handle errors/empty data and complete the README acceptance scenarios.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        
 
        
    }
    func dynamicTableViewHight(){
        walletTableView.layoutIfNeeded()
        walletTabelViewHightConstraint.constant =
        walletTableView.contentSize.height
        
        conversionTableView.layoutIfNeeded()
        conversinTabelViewHightConstraint.constant =
        conversionTableView.contentSize.height
    }
    func cellRejestration() {
        let nib1 = UINib(nibName: "WalletCell", bundle: nil)
        walletTableView.register(nib1, forCellReuseIdentifier: "WalletCell")
        
        let nib2 = UINib(nibName: "ConversionCell", bundle: nil)
        conversionTableView.register(nib2, forCellReuseIdentifier: "ConversionCell")
    }
    //
    //    Optional("#00A63E")
    //    Optional("#065fb1")
    //    Optional("#4ddb50")
    func walletCellBinding() {
        
        configuration
            .asObservable()
            .compactMap { config -> [ConversionConfiguration.Wallet]? in
                return config?.wallets
            }
            .bind(to: walletTableView.rx.items(
                cellIdentifier: "WalletCell",
                cellType: WalletCell.self
            )) { index, item, cell in
                cell.configer(item.name, "\(item.balance)", item.color ?? "#065fb1")
                print("walletID",item.id)
                self.dynamicTableViewHight()
            }
            .disposed(by: disposeBag)
      
        
        
        
    }
    func conversionCellBinding() {
        
        configuration
            .asObservable()
            .compactMap{ config -> [ConversionConfiguration.Option]? in
                return config?.options
            }.bind(to: conversionTableView.rx.items(cellIdentifier: "ConversionCell" , cellType: ConversionCell.self)){
                index, item,cell in
                cell.configer(item.name,item.points,item.pointsNeeded)
                print("conversionID" ,item.id)
                self.dynamicTableViewHight()
                
            }.disposed(by: disposeBag)
        
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
    
    
    func addNewConvertion(){
        conversionAPI.PostNewConversion().subscribe(onSuccess: { [weak self] result in
            print(result.data)
            self?.postRespons.accept(result)
            self?.isLoading.accept(false)
        
        }, onFailure: { [weak self] error in
            self?.loadError.accept(error.localizedDescription)
            self?.isLoading.accept(false)
            print(error)
        }).disposed(by: disposeBag)
    }
    func loadgetRedemptionCatalog(){
        conversionAPI.fetcRedemptionCatalog().subscribe(onSuccess: { [weak self] result in
            print(result.data)
            self?.redemptionCatalogRespons.accept(result)
            self?.isLoading.accept(false)
        
        }, onFailure: { [weak self] error in
            self?.loadError.accept(error.localizedDescription)
            self?.isLoading.accept(false)
            print(error)
        }).disposed(by: disposeBag)
    }
    
}
