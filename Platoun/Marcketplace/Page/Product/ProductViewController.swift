//
//  ProductViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ProductViewControllerDelegate {
    func haveClickLike(productId: String, isLike: Bool)
}

extension CGFloat {
    var radian: CGFloat {
        get { self * CGFloat.pi/180 }
    }
}

class ProductViewController: LightViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, PageImageControllerDelegate {
    private static let marketplaceItemHeight: CGFloat = 240
    private static let marketplaceItemWidth: CGFloat = 160

    
    static func instance(productId: String) -> ProductViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        vc.productId = productId
        return vc
    }
    
    var delegate: ProductViewControllerDelegate?
    
    let segueShowJoinGroup = "showJoinGroup"
    
    private var productId: String!
    private var product: Product?
    
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var soloPriceButton: UILabel!
    @IBOutlet weak var groupPriceButton: UILabel!
    @IBOutlet weak var productRate: RateView!
    @IBOutlet weak var containerImages: UIView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productMark: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var shippingInfoContent: UIView!
    @IBOutlet weak var shippingInfoArrow: UIImageView!
    @IBOutlet weak var shippingInfoLabel: UILabel!
    @IBOutlet weak var pickerViewContainer: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var alsoItemCountLabel: UILabel!
    @IBOutlet weak var marketplaceAlsoLike: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var shippingInfoIsVisible = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.shippingInfoContent.isHidden = !self.shippingInfoIsVisible
                
                UIView.setAnimationCurve(.linear)
                let rotations: CGFloat = !self.shippingInfoIsVisible ? 0 : 90
                self.shippingInfoArrow.transform = CGAffineTransform(rotationAngle: rotations.radian)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emptyView.isHidden = false
        self.scrollView.isHidden = true
        self.soloPriceButton.text = "Buy it now".localise() + "\n"
        self.groupPriceButton.text = "Buy in group".localise() + "\n"
        
        self.updateLike()
        self.reload(forceUpdate: false)
    }
    
    func reload(forceUpdate: Bool = false) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Interactor.shared.fetchProduct(forceUpdate: forceUpdate, userId: userId, productId: self.productId) { product in
            self.scrollView.refreshControl?.endRefreshing()
            self.scrollView.isHidden = false
            self.emptyView.isHidden = true
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
            self.updateProduct(product: product)
        }
    }
    
    @objc func forceUpdate() {
        self.reload(forceUpdate: true)
    }
    
    func updateProduct(product: Product) {
        self.product = product
        self.title = product.name
        self.productName.text = product.name
        self.productMark.text = product.brandName
        self.productDesc.text = product.description
        self.soloPriceButton.text = "Buy it now".localise() + "\n\(product.price)€"
        self.groupPriceButton.text = "Buy in group".localise() + "\n\(product.groupPrice)€"
        self.productRate.rate = 0//product.rate
        self.colorSelect = product.colors.first
        self.optionsSelect = product.productAges.first!
        self.likeButton.state = productLike(product.id)
        self.productRate.rateNumber = 0//product.nbRate
        self.shippingInfoLabel.text = product.shippingInfo
        
        let itemText: String
        if product.alsoLike.count > 1{
            itemText = "%d items"
        } else {
            itemText = "%d item"
        }
        
        self.alsoItemCountLabel.text = itemText.localise(product.alsoLike.count)
        self.collectionView.reloadData()
    }
    
    func updateCount(current: Int, total: Int) {
        indicatorStackView.arrangedSubviews.enumerated().forEach {
            $0.1.backgroundColor = $0.0 == current ? UIColor(hex: "#222222") : UIColor.clear
        }
        
        if indicatorStackView.arrangedSubviews.count < total {
            while indicatorStackView.arrangedSubviews.count < total {
                let view = UIView()
                view.backgroundColor = indicatorStackView.arrangedSubviews.count == current ? UIColor(hex: "#222222") : UIColor.clear
                indicatorStackView.addArrangedSubview(view)
            }
        } else if indicatorStackView.arrangedSubviews.count > total {
            while indicatorStackView.arrangedSubviews.count > total {
                indicatorStackView.arrangedSubviews.last?.removeFromSuperview()
            }
        }
    }
    
    var pageImageController: PageImageController? {
        didSet {
            self.pageImageController?.countDelegate = self
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "pageImageController":
            guard let vc = segue.destination as? PageImageController else { return }
            self.pageImageController = vc
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.collectionViewLayout = makeLayout()
        
        self.likeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.likeCurrentProduct)))
        pickerView.delegate = self
        pickerView.dataSource = self
        
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(forceUpdate), for: .valueChanged)
        
        self.scrollView.delegate = self
        self.scrollView.isHidden = true
        self.emptyView.isHidden = false
        self.title = ""
    }
    
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return LayoutBuilder.buildGallerySectionLayout(
                size: NSCollectionLayoutSize(
                    widthDimension: .absolute(Self.marketplaceItemWidth),
                    heightDimension: .absolute(Self.marketplaceItemHeight)))
        }
        return layout
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        actionValidatePicker("")
    }
    
    var pickerIsForColor: Bool? = nil
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerIsForColor = self.pickerIsForColor else { return 0 }
        return pickerIsForColor ? (self.product?.colors.count ?? 0) : (self.product?.productAges.count ?? 0)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let pickerIsForColor = self.pickerIsForColor else { return nil }
        return pickerIsForColor ? self.product!.colors[row].name : self.product!.productAges[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let pickerIsForColor = self.pickerIsForColor else { return }
        if pickerIsForColor {
            colorSelect = self.product!.colors[row]
        } else {
            optionsSelect = self.product!.productAges[row]
        }
    }

    @objc func likeCurrentProduct() {
        guard let product = self.product, let userId = Auth.auth().currentUser?.uid else { return }
        self.likeButton.state = .processing
        Interactor.shared.postLike(userId: userId, liked: !product.isLike, productId: productId) {
            self.product?.isLike = $0 ?? product.isLike
            self.updateLike()
//            self.delegate?.haveClickLike(productId: product.id, isLike: $0 ?? product.isLike)
        }
    }
    @IBOutlet weak var optionsButton: DropDownView!
    var optionsSelect: String = "" {
        didSet {
            optionsButton.text = optionsSelect
        }
    }
    @IBAction func optionsPressed(_ sender: Any) {
        optionsButton.toogleArrow()
        
        if pickerIsForColor == nil {
            self.pickerIsForColor = false
            UIView.animate(withDuration: 0.2) {
                self.pickerViewContainer.isHidden = false
            }
        } else if pickerIsForColor == false {
            self.pickerIsForColor = nil
            UIView.animate(withDuration: 0.2) {
                self.pickerViewContainer.isHidden = true
            }
        } else {
            colorButton.toogleArrow()
            pickerIsForColor = false
            UIView.animate(withDuration: 0.2) {
                self.pickerViewContainer.isHidden = false
            }
        }
        pickerView.reloadComponent(0)
        guard let index = self.product?.productAges.firstIndex(of: self.optionsSelect) else { return }
        pickerView.selectRow(index, inComponent: 0, animated: false)
    }
    @IBOutlet weak var colorButton: DropDownView!
    var colorSelect: Product.Color? = nil {
        didSet {
            colorButton.text = colorSelect?.name ?? "Colors".localise()
            guard let product = self.product else { return }
            self.pageImageController?.initialiseViewControllers(count: self.colorSelect?.images.count ?? 1)
            let urls = (self.colorSelect?.images ?? [product.iconName]).map { URL(string: $0)! }
            self.pageImageController?.updateImages(images: urls)
        }
    }
    
    @IBAction func actionValidatePicker(_ sender: Any) {
        if pickerIsForColor != nil {
            if pickerIsForColor == true {
                colorButton.toogleArrow()
            } else if pickerIsForColor == false {
                optionsButton.toogleArrow()
            }
            UIView.animate(withDuration: 0.2) {
                self.pickerViewContainer.isHidden = true
            }
        }
        self.pickerIsForColor = nil
    }
    @IBAction func colorPressed(_ sender: Any) {
        colorButton.toogleArrow()
        
        
        if pickerIsForColor == nil {
            self.pickerIsForColor = true
            UIView.animate(withDuration: 0.2) {
                self.pickerViewContainer.isHidden = false
            }
        } else if pickerIsForColor == true {
            self.pickerIsForColor = nil
            UIView.animate(withDuration: 0.2) {
                self.pickerViewContainer.isHidden = true
            }
        } else {
            optionsButton.toogleArrow()
            pickerIsForColor = true
            UIView.animate(withDuration: 0.2) {
                self.pickerViewContainer.isHidden = false
            }
        }
        pickerView.reloadComponent(0)
        guard let index = self.product?.colors.firstIndex(where: { $0 == self.colorSelect }) else { return }
        pickerView.selectRow(index, inComponent: 0, animated: false)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyInGroupAction(_ sender: Any) {
        guard let product = self.product else { return }
        let vc = JoinGroupViewController.instance(product: product.toSummary(), scrollBottom: false)
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func actionshippingInfo(_ sender: Any) {
        shippingInfoIsVisible = !shippingInfoIsVisible
    }
    @IBAction func actionMoreInformation(_ sender: Any) {
        guard let moreInfo = self.product?.moreInfo, let url = URL(string: moreInfo) else {
            let alert = UIAlertController(title: "Oups !".localise(), message: "We do not have any more information for you at this time.".localise(), preferredStyle: .alert)
            let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
            action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
            
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func buyItNowAction(_ sender: Any) {
        guard let product = self.product, let url = URL(string: product.link) else { return }
        UIApplication.shared.open(url)
    }
}

extension ProductViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.product?.alsoLike.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let products = self.product?.alsoLike ?? []
        if products.count > indexPath.row {
            return CellBuilder.getCellProposed(in: collectionView, at: indexPath, for: products[indexPath.row], with: self)
        } else {
            return UICollectionViewCell()
        }
    }
}

extension ProductViewController: MarketplaceCategoryViewAction {
    func getViewController() -> UIViewController? {
        return self
    }
    
    func onClickLikeProduct(productId: String, isLiked: Bool) {}
    
    func seeAll(category: Category) {}
}

extension ProductViewController: ContainerLikedProduct {
    func updateLike() {
        guard let product = self.product else { return }
        updateProduct(product: product)
    }
}
