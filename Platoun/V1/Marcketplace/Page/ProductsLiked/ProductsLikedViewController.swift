//
//  ProductsLikedViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 23/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProductsLikedViewController: LightViewController {
    static func instance() -> ProductsLikedViewController {
        let vc = ProductsLikedViewController.instanceStoryboard()
        return vc
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var products: [ProductLiked] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.refreshControl = self.collectionView.refreshControl ?? UIRefreshControl()
        self.collectionView.refreshControl?.beginRefreshing()
        self.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.collectionViewLayout = makeLayout()
        self.collectionView.refreshControl = self.collectionView.refreshControl ?? UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
    }
    
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return LayoutBuilder.buildTwoCollomLayout(height: .absolute(240))
        }
        return layout
        
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reload() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Interactor.shared.fetchLiked(userId: userId) { (products) in
            self.products = products
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: 0))
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension ProductsLikedViewController: UICollectionViewDelegate {}

extension ProductsLikedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if products.count > indexPath.row {
            return CellBuilder.getCell(in: collectionView, at: indexPath, for: products[indexPath.row], with: self)
        } else {
            return UICollectionViewCell()
        }
    }
}

extension ProductsLikedViewController: ProductLikeCollectionViewCellDelegate {
    func afterLike(productId: String, isLiked: Bool) {
//        self.reload()
        DispatchQueue.main.async {
            if isLiked == false, let index = self.products.firstIndex(where: { $0.id == productId }) {
                self.products.remove(at: index)
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
}
