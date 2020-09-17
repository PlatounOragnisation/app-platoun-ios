//
//  MarketplaceViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 11/01/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol ContainerLikedProduct {
    func updateLike()
}

func productLike(_ productId: String) -> LikeButton.State {
    guard let userId = HttpServices.shared.user?.id else { return .noSelected }
    switch Interactor.shared.productLike[userId]?[productId] {
    case .yes:
        return .selected
    case .no:
        return .noSelected
    case .loading:
        return .processing
    case .none:
        return .noSelected
    }
}

class MarketplaceViewController: LightViewController, ContainerLikedProduct {
    
    func updateLike() {
        self.setupStackView()
    }
    
    static func instance() -> MarketplaceViewController {
        let vc = MarketplaceViewController.instanceStoryboard()
        return vc
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterByView: UIView!
    @IBOutlet weak var categoriesStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emptyScrollView: UIScrollView!
    
    var searchBar: UISearchBar?
    
    var interactor = MarketplaceInteractor()
    
    var categoriesFiltred: MarketplaceFilters = MarketplaceFilters(categories: [:], groupDeals: nil) {
        didSet { setupStackView() }
    }
    
    var categories: [Category] = []
    
    var products: [ProductSummary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        self.scrollView.isHidden = false
        self.emptyScrollView.isHidden = true
        
        self.emptyScrollView.refreshControl = UIRefreshControl()
        self.emptyScrollView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)

        
        self.scrollView.refreshControl?.beginRefreshing()
        self.reload()
        
        (self.navigationController as? RootViewController)?.setMenu(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.products.count > 0 else { return }
        self.updateLike()
    }
    
    @IBAction func actionReload(_ sender: Any) {
        self.actionFilterBy()
    }
    
    @IBAction func onClicSearch(_ sender: Any) {
        self.showSearch(isVisible: self.navigationItem.titleView == nil)
        self.setupStackView()
    }
    
    func showSearch(isVisible: Bool) {
        
        if isVisible {
            self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 20))
            self.navigationItem.titleView = self.searchBar
            self.searchBar?.delegate = self
            self.searchBar?.becomeFirstResponder()
        } else {
            self.searchBar?.text = ""
            self.navigationItem.titleView = nil
        }
    }
    
    @objc func reload() {
        self.interactor.fetchCategories { categories in
            self.interactor.fetchData { products in
                self.products = products
                self.scrollView.refreshControl?.endRefreshing()
                self.emptyScrollView.refreshControl?.endRefreshing()
                
                self.categories = categories
                var categoriesFiltred: [Category: Bool] = self.categoriesFiltred.categories
                categories.forEach {
                    if !categoriesFiltred.keys.contains($0) {
                        categoriesFiltred[$0] = true
                    }
                }
                self.categoriesFiltred.categories = categoriesFiltred
                self.setupStackView()
            }
        }
    }
    
    @IBAction func actionFilterBy() {
        let vc = MarketplaceFilterViewController.instance(filters: self.categoriesFiltred, delegate: self)
        
        self.present(vc, animated: true)
    }
    
    @IBAction func actionOpenDrawer(_ sender: Any) {
        (self.navigationController as? RootViewController)?.handleMenuButton()
        self.showSearch(isVisible: false)
    }
    
    
    fileprivate func setupStackView() {
        var dict: [Category: [ProductSummary]] = [:]
        
        categories
            .filter { self.categoriesFiltred.categories[$0] ?? false }
            .forEach { category in
                let rangeProducts = self.getFiltredProducts()
                    .filter { $0.categoryId == category.id }
                let products = Array(rangeProducts[0..<min(12, rangeProducts.count)])
                if products.count > 0 {
                    dict[category] = products
                }
        }
        
        dict
            .sorted(by: { $0.key.order < $1.key.order })
            .enumerated()
            .forEach { (arg0) in
                let (index, (category, products)) = arg0
                
                let view = self.categoriesStackView.arrangedSubviews.getOrNil(index) as? MarketplaceCategoryView
                
                let categoryView = view ?? MarketplaceCategoryView()
                categoryView.delegate = self
                categoryView.setup(by: category, and: products, parent: self)
                
                if view == nil {
                    self.categoriesStackView.addArrangedSubview(categoryView)
                    categoryView.translatesAutoresizingMaskIntoConstraints = false
                    let height: CGFloat = categoryView.getHeight()                    
                    categoryView.heightAnchor.constraint(equalToConstant: height).isActive = true
                }
        }
        
        while dict.count < self.categoriesStackView.arrangedSubviews.count, let last = self.categoriesStackView.arrangedSubviews.last {
            last.removeFromSuperview()
        }
        
        
        
        let search = self.searchBar?.text ?? ""
        self.scrollView.isHidden = dict.count == 0 || !search.isEmpty
        self.collectionView.isHidden = self.getFiltredProducts().count == 0 || search.isEmpty
        self.emptyScrollView.isHidden = !self.scrollView.isHidden || !self.collectionView.isHidden
        
        if !self.collectionView.isHidden {
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    func getFiltredProducts() -> [ProductSummary] {
        let search = self.searchBar?.text ?? ""
        
        if self.navigationItem.titleView == nil || search.count == 0 {
            return self.products.filter {
                    switch self.categoriesFiltred.groupDeals {
                    case .gd5:
                        return $0.percentage >= 5
                    case .gd10:
                        return $0.percentage >= 10
                    case .gd15:
                        return $0.percentage >= 15
                    case .none:
                        return true
                    }
            }
        } else {
            return self.products.filter {
                $0.brandName.lowercased().contains(search.lowercased()) ||
                    $0.name.lowercased().contains(search.lowercased()) ||
                    $0.description.lowercased().contains(search.lowercased())
            }
        }
    }
}

extension MarketplaceViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.setupStackView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder()
        if self.searchBar?.text?.isEmpty ?? true {
            showSearch(isVisible: false)
        }
    }
}

extension MarketplaceViewController: MarketplaceCategoryViewAction {
    func getViewController() -> UIViewController? {
        return self
    }
    
    func seeAll(category: Category) {
        let vc = CategoryViewController.instance(
            category: category,
            products: self.products.filter { $0.categoryId == category.id })
        
        self.show(vc, sender: nil)
    }
        
    func onClickLikeProduct(productId: String, isLiked: Bool) {}
}

extension MarketplaceViewController: FilterViewControllerDelegate {
    func update(filters: MarketplaceFilters) {
        self.categoriesFiltred = filters
    }
}

extension MarketplaceViewController: DrawerViewControllerDelegate {
    func showGroupStatus() {
        (self.navigationController as? RootViewController)?.handleMenuButton()
        let vc = PromocodesViewController.instance(isForPromocode: false)
        self.show(vc, sender: nil)
    }
    
    func showProductsLiked() {
        (self.navigationController as? RootViewController)?.handleMenuButton()
        let vc = ProductsLikedViewController.instance()
        self.show(vc, sender: nil)
    }
    
    func showSupport() {
        (self.navigationController as? RootViewController)?.handleMenuButton()
        guard let url = URL(string: "https://www.momunity.com/kontakt") else { return }
        UIApplication.shared.open(url)
    }
    
    func showPromoCode() {
        (self.navigationController as? RootViewController)?.handleMenuButton()
        let vc = PromocodesViewController.instance(isForPromocode: true)
        self.show(vc, sender: nil)
    }
}

extension MarketplaceViewController: UICollectionViewDelegate {}

extension MarketplaceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio: Double = 185 / 327
        let witdh = self.collectionView.frame.width / 2
        
        return CGSize(width: witdh , height: witdh / CGFloat(ratio))
    }
}

extension MarketplaceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getFiltredProducts().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.identifier, for: indexPath) as? CategoryViewCell else {
            return UICollectionViewCell()
        }
        let products = getFiltredProducts()
        cell.setup(product: products[indexPath.row], delegate: self, parent: self)
        
        return cell
    }
}

extension MarketplaceViewController: ItemShopDelegate {
    func onClicLike(productId: String, isLiked: Bool) {}
}
