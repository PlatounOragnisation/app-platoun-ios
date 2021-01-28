//
//  FilterViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 12/01/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate {
    func update(filters: MarketplaceFilters)
}

struct MarketplaceFilters {
    var categories: [Category: Bool]
    var groupDeals: GroupDeals?
    
    enum GroupDeals {
        case gd5, gd10, gd15
    }
    
    
    func filter(_ category: Category, _ products: [ProductSummary]) -> [ProductSummary] {
        if categories[category] == false { return [] }
        switch self.groupDeals {
        case .gd5:
            return products.filter { $0.percentage >= 5 }
        case .gd10:
            return products.filter { $0.percentage >= 10 }
        case .gd15:
                return products.filter { $0.percentage >= 15 }
        case .none:
            return products
        }
    }
}

class MarketplaceFilterViewController: LightViewController, CheckableItemViewAction {
    
    static func instance(filters: MarketplaceFilters, delegate: FilterViewControllerDelegate) -> MarketplaceFilterViewController{
        let vc = MarketplaceFilterViewController.instanceStoryboard()
        vc.filters = filters
        vc.delegate = delegate
        return vc
    }
    
    var filters: MarketplaceFilters = MarketplaceFilters(categories: [:], groupDeals: nil)
    var delegate: FilterViewControllerDelegate?
    
    @IBOutlet weak var groupDeals5: CheckableItemView!
    @IBOutlet weak var groupDeals10: CheckableItemView!
    @IBOutlet weak var groupDeals15: CheckableItemView!
    
    @IBOutlet weak var categoryStackView: UIStackView!
    var liaison: [Category: CheckableItemView] = [:]
        
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var itemFilters: UIBarButtonItem!
    
    var allIsCheck: Bool = false
    
    @IBAction func toogleFilters(_ sender: Any) {
        allIsCheck = !allIsCheck
        checkAll(value: allIsCheck)
    }
    
    @IBAction func seeOffersPressed(_ sender: Any) {
        self.delegate?.update(filters: self.filters)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func checkAll(value: Bool) {
        let name = value ? "ic-checkbox-on" : "ic-checkbox-off"
        itemFilters.image = UIImage(named: name)

        self.liaison.keys.forEach {
            self.liaison[$0]?.checked = value
        }
        
        self.liaison.keys.forEach {
            if let view = self.liaison[$0] {
                if value {
                    self.append(switchObj: view)
                } else {
                    self.removed(switchObj: view)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupDeals5.delegate = self
        self.groupDeals10.delegate = self
        self.groupDeals15.delegate = self
        
        self.filters.categories
            .sorted(by: { $0.key.order < $1.key.order })
            .forEach { (arg0) in
                let (key, value) = arg0
                let view = CheckableItemView()
                view.isLocalized = false
                view.text = arg0.key.name
                view.translatesAutoresizingMaskIntoConstraints = false
                self.categoryStackView.addArrangedSubview(view)
                view.heightAnchor.constraint(equalToConstant: 50).isActive = true
                view.checked = value
                view.delegate = self
                liaison[key] = view
        }
        
        switch filters.groupDeals {
        case .gd5:
            self.groupDeals5.checked = true
            self.groupDeals10.checked = false
            self.groupDeals15.checked = false
        case .gd10:
            self.groupDeals5.checked = false
            self.groupDeals10.checked = true
            self.groupDeals15.checked = false
        case .gd15:
            self.groupDeals5.checked = false
            self.groupDeals10.checked = false
            self.groupDeals15.checked = true
        case .none:
            self.groupDeals5.checked = false
            self.groupDeals10.checked = false
            self.groupDeals15.checked = false
        }
        
        let countTrue = filters.categories.values.filter { $0 }.count
        
        if filters.categories.count == countTrue {
            allIsCheck = true
            checkAll(value: true)
        } else if countTrue == 0 {
            allIsCheck = false
            checkAll(value: false)
        } else {
            filters.categories.forEach { (arg0) in
                let (key, value) = arg0
                liaison[key]?.checked = value
            }
        }
        
    }
    
    func toogle(view: CheckableItemView) {
        if !view.checked {
            removed(switchObj: view)
        } else {
            append(switchObj: view)
        }
    }
    
    func append(switchObj: CheckableItemView) {
        switch switchObj {
        case groupDeals5:
            filters.groupDeals = .gd5
            self.groupDeals10.checked = false
            self.groupDeals15.checked = false
        case groupDeals10:
            filters.groupDeals = .gd10
            self.groupDeals5.checked = false
            self.groupDeals15.checked = false
        case groupDeals15:
            filters.groupDeals = .gd15
            self.groupDeals5.checked = false
            self.groupDeals10.checked = false
        default:
            guard let id = (self.liaison.first { switchObj == $0.1 })?.key else { return }
            self.filters.categories[id] = true
        }
    }
    
    func removed(switchObj: CheckableItemView) {
        switch switchObj {
        case groupDeals5:
            filters.groupDeals = nil
        case groupDeals10:
            filters.groupDeals = nil
        case groupDeals15:
            filters.groupDeals = nil
        default:
            guard let id = (self.liaison.first { switchObj == $0.1 })?.key else { return }
            self.filters.categories[id] = false
        }
    }
    
    
}
