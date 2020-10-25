//
//  CellBuilder.swift
//  Platoun
//
//  Created by Flavian Mary on 22/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class CellBuilder {
    static func getCell(in collectionView: UICollectionView,at indexPath: IndexPath,for category: Category, and products: [ProductSummary], with vc: UIViewController) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell {
            cell.setup(category: category, products: products, parent: vc)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    static func getCell(in collectionView: UICollectionView,at indexPath: IndexPath,for product: ProductSummary, with vc: UIViewController) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as? ProductCollectionViewCell {
            cell.setup(product: product, parent: vc)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    static func getCellProposed(in collectionView: UICollectionView,at indexPath: IndexPath,for product: ProductSummary, with vc: UIViewController) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductProposedCollectionViewCell.identifier, for: indexPath) as? ProductProposedCollectionViewCell {
            cell.setup(product: product, parent: vc)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    static func getCell(in collectionView: UICollectionView, at indexPath: IndexPath, for product: ProductLiked, with vc: ProductLikeCollectionViewCellDelegate) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductLikeCollectionViewCell.identifier, for: indexPath) as? ProductLikeCollectionViewCell {
            cell.setup(product: product, parent: vc)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    static func getEmptyCell(in collectionView: UICollectionView,at indexPath: IndexPath, showFilter: @escaping ()->Void) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyProductsCollectionViewCell.identifier, for: indexPath) as? EmptyProductsCollectionViewCell {
            cell.showFilterPage = showFilter
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}
