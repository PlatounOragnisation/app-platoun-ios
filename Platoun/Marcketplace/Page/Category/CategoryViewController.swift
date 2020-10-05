//
//  CategorieViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 08/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class LightViewController: UIViewController {
    @available(iOS 12.0, *)
    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        get { .light }
        set {}
    }
    
}


class CategoryViewController: LightViewController {
    
    static func instance(category: Category, products: [ProductSummary]) -> CategoryViewController {
        let vc = CategoryViewController.instanceStoryboard()
        vc.category = category
        vc.products = products
        return vc
    }
    
    @IBOutlet weak var titleIcon: UIImageView!
    @IBOutlet weak var titleText: UILabelLocalized!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sortButton: UIButtonLocalized!
    
    var category: Category!
    var filters = CategoryFilter(
        minPrice: 0,
        maxPrice: -1,
        groupDeals: nil,
        ageRange: [],
        allBrands: true,
        brands: [])
    
    var products: [ProductSummary] = []
    
    var maxPrice: Int {
        get { products.sorted(by: { $0.groupPrice > $1.groupPrice }).first?.groupPrice ?? 0 }
    }
    
    func getProductsFiltred() -> [ProductSummary] {
        let products = self.products
            .filter {
                var priceOk = self.filters.minPrice <= $0.groupPrice
                if self.filters.maxPrice != -1 {
                    priceOk = priceOk && $0.groupPrice <= self.filters.maxPrice
                }
                
                let voucherOk: Bool
                switch self.filters.groupDeals {
                case .gd5:
                    voucherOk = $0.percentage >= 5
                case .gd10:
                    voucherOk = $0.percentage >= 10
                case .gd15:
                    voucherOk = $0.percentage >= 15
                case .none:
                    voucherOk = true
                }
                
                var ageOk = false
                for age in self.filters.ageRange {
                    if $0.productAges.contains(age) {
                        ageOk = true
                        break
                    }
                }
                
                ageOk = self.filters.ageRange.isEmpty || ageOk
                                
                let brandOK = self.filters.allBrands || self.filters.brands.contains($0.brandName)
                return priceOk && voucherOk && brandOK && ageOk
        }
                
        return products.sorted(by: {
            self.isLowestToHigh ? ($0.price < $1.price) : ($0.price > $1.price)
        })
    }
    
    var isLowestToHigh = true {
        didSet {
            let title = self.isLowestToHigh ? "Price: Lowest to Highest" : "Price: Highest to lowest"
            sortButton.localizedTitle = title
        }
    }
    
    func update() {
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    @IBAction func actionSort(_ sender: Any) {
        isLowestToHigh = !isLowestToHigh
        update()
    }
    @IBAction func actionFilters(_ sender: Any) {
        var productAges = [String]()
        self.products.forEach { product in
            productAges = productAges.merged(with: product.productAges , key: { $0 })
        }
        let content = CategoryFilterViewController.Content(
            category: category,
            maxPrice: maxPrice,
            filter: filters,
            productAges: productAges )
        let vc = CategoryFilterViewController.instance(content: content, delegate: self)
        
        self.present(vc, animated: true)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let category = self.category else { return }
        
        titleIcon.setImage(with: URL(string: category.icon), placeholder: nil, options: .progressiveLoad)
        titleText.text = category.name
        
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLike()
    }
}

extension CategoryViewController: CategoryFilterViewControllerDelegate {
    func sort(filters: CategoryFilter) {
        self.filters = filters
        self.update()
    }
}

extension CategoryViewController: UICollectionViewDelegate {}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio: Double = 185 / 327
        let witdh = self.collectionView.frame.width / 2
        
        return CGSize(width: witdh , height: witdh / CGFloat(ratio))
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getProductsFiltred().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.identifier, for: indexPath) as? CategoryViewCell else {
            return UICollectionViewCell()
        }
        let products = getProductsFiltred()
        cell.setup(product: products[indexPath.row], delegate: self, parent: self)
        
        return cell
    }
}

extension CategoryViewController: ItemShopDelegate {
    func getViewController() -> UIViewController? { return self }
    
    func onClicLike(productId: String, isLiked: Bool) {}
}

extension CategoryViewController: ContainerLikedProduct {
    func updateLike() {
        update()
    }
}
