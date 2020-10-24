//
//  MarketplaceViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 22/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

extension Array where Element == MarketplaceViewController
                    .Section {
    func sorted() -> [MarketplaceViewController
    .Section] {
        return self.sorted(by: { $0.category.order < $1.category.order })
    }
}

protocol ContainerLikedProduct {
    func updateLike()
}

func productLike(_ productId: String) -> LikeButton.State {
    guard let userId = Auth.auth().currentUser?.uid else { return .noSelected }
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

class MarketplaceViewController: LightViewController, ContainerLikedProduct, ReloadedViewController {
    
    private static let marketplaceItemHeight: CGFloat = 300
    private static let marketplaceItemWidth: CGFloat = 160
    private static let marketplaceHeaderHeight: CGFloat = 90
    
    struct Section {
        let category: Category
        var products: [ProductSummary]
        
        mutating func add(product: ProductSummary) {
            self.products.append(product)
        }
    }
    
    enum MarketplaceLayout {
        case normal([Section])
        case search([ProductSummary])
        case empty
    }
    
    func updateLike() {
        self.reload()
    }
    
    var marketPlaceLayout: MarketplaceLayout = .normal([])
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionContentView: UIView!
    @IBOutlet weak var filterByView: UIView!
    
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            switch self.marketPlaceLayout {
            case .normal:
                if section % 2 == 0 {
                    return LayoutBuilder.buildTextSectionLayout(
                        height: .absolute(Self.marketplaceHeaderHeight))
                } else {
                    return LayoutBuilder.buildGallerySectionLayout(
                        size: NSCollectionLayoutSize(
                            widthDimension: .absolute(Self.marketplaceItemWidth),
                            heightDimension: .absolute(Self.marketplaceItemHeight)))
                }
            case .search:
                return LayoutBuilder.buildTwoCollomLayout(height: .absolute(300))
            case .empty:
                return LayoutBuilder.buildTextSectionLayout(height: .absolute(self.collectionContentView.frame.height))
            }
        }
        return layout
        
    }
    
    var searchBar: UISearchBar?
    
    var interactor = MarketplaceInteractor()
    
    var categoriesFiltred: MarketplaceFilters = MarketplaceFilters(categories: [:], groupDeals: nil)
    
    var productsByCategories: [Section] = []
    
    func filter(products: [ProductSummary], for search: String) -> [ProductSummary] {
        return products.filter {
            $0.brandName.lowercased().contains(search.lowercased()) ||
                $0.name.lowercased().contains(search.lowercased()) ||
                $0.description.lowercased().contains(search.lowercased())
        }
    }
    
    func updateLayout() {
        let search = self.searchBar?.text ?? ""
        
        if self.navigationItem.titleView == nil || search.count == 0 {
            var res:[Section] = []
            
            self.productsByCategories.forEach {
                let products = self.categoriesFiltred.filter($0.category, $0.products)
                if products.count > 0 {
                    res.append(Section(category: $0.category, products: products))
                }
            }
            self.marketPlaceLayout = res.isEmpty ? .empty : .normal(res.sorted())
        } else {
            let products:[ProductSummary] = self.productsByCategories.reduce([], { $0 + $1.products })
            let productsFiltred = self.filter(products: products, for: search)
            self.marketPlaceLayout = productsFiltred.isEmpty ? .empty : .search(productsFiltred)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.collectionViewLayout = self.makeLayout()
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(self.reload), for: .valueChanged)
    }
    
    var first = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if first {
            first = false
            self.view.applyGradientHorizontal(colours: [UIColor(hex: "#F7F6FB")!, ThemeColor.White])
        }
        self.updateLike()
    }
    
    @IBAction func actionReload(_ sender: Any) {
        self.actionFilterBy()
    }
    
    @IBAction func onClicSearch(_ sender: Any) {
        self.showSearch(isVisible: self.navigationItem.titleView == nil)
        self.updateLayout()
        self.collectionView.reloadData()
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
        let uid = Auth.auth().currentUser?.uid
        
        self.interactor.fetchDataByCategory(uid: uid) { productsByCategories in
            self.productsByCategories = productsByCategories
            self.productsByCategories.forEach { section in
                if self.categoriesFiltred.categories[section.category] == nil {
                    self.categoriesFiltred.categories[section.category] = true
                }
            }
            self.updateLayout()
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func showHeader() -> Bool {
        return self.navigationItem.titleView == nil || (self.searchBar?.text ?? "").count == 0
    }
    
    @IBAction func actionFilterBy() {
        let vc = MarketplaceFilterViewController.instance(filters: self.categoriesFiltred, delegate: self)
        
        self.present(vc, animated: true)
    }

}

extension MarketplaceViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.updateLayout()
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder()
        if self.searchBar?.text?.isEmpty ?? true {
            showSearch(isVisible: false)
        }
        self.updateLayout()
    }
}

extension MarketplaceViewController: FilterViewControllerDelegate {
    func update(filters: MarketplaceFilters) {
        self.categoriesFiltred = filters
        self.updateLayout()
        self.collectionView.reloadData()
    }
}

extension MarketplaceViewController: UICollectionViewDelegate {}

extension MarketplaceViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch self.marketPlaceLayout {
        case .normal(let sections):
            return sections.count * 2
        case .search:
            return 1
        case .empty:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch self.marketPlaceLayout {
        case .normal(let sections):
            if section % 2 == 0 {
                return 1
            } else {
                return sections[(section - 1)/2].products.count
            }
        case .search(let products):
            return products.count
        case .empty:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch self.marketPlaceLayout {
        case .normal(let sections):
            let indexSection = indexPath.section % 2 == 0 ? indexPath.section : indexPath.section - 1
            let section = sections[indexSection/2]
            let product: ProductSummary? = section.products.count > indexPath.row ? section.products[indexPath.row] : nil
            if indexPath.section % 2 == 0 {
                return CellBuilder.getCell(in: collectionView, at: indexPath, for: section.category, and: section.products, with: self)
            } else if let product = product {
                return CellBuilder.getCell(in: collectionView, at: indexPath, for: product, with: self)
            } else {
                return UICollectionViewCell()
            }

        case .search(let products):
            let product: ProductSummary? = products.count > indexPath.row ? products[indexPath.row] : nil
            if let product = product {
                return CellBuilder.getCell(in: collectionView, at: indexPath, for: product, with: self)
            } else {
                return UICollectionViewCell()
            }
        case .empty:
            return CellBuilder.getEmptyCell(in: collectionView, at: indexPath) {
                self.actionFilterBy()
            }
        }
    }
}
