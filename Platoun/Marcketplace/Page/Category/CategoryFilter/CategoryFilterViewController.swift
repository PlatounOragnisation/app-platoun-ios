//
//  CategoryFilterViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 09/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import MultiSlider

struct CategoryFilter {
    var minPrice: Int
    var maxPrice: Int
    var groupDeals: GroupDeals?
    var ageRange: [String]
    var allBrands: Bool
    var brands: [String]
    
    enum GroupDeals {
        case gd5, gd10, gd15
    }
}

protocol CategoryFilterViewControllerDelegate {
    func sort(filters: CategoryFilter)
}

class CategoryFilterViewController: LightViewController, RoundedLabelAction, ImageSpacingBorderViewAction {
    
    struct Content {
        let category: Category
        let maxPrice: Int
        let filter: CategoryFilter
        let productAges: [String]
    }
    static func instance(content: Content, delegate: CategoryFilterViewControllerDelegate) -> CategoryFilterViewController {
        let vc = CategoryFilterViewController.instanceStoryboard()
        vc.category = content.category
        vc.maxPrice = content.maxPrice
        vc.filters = content.filter
        vc.productAges = content.productAges
        vc.delegate = delegate
        return vc
    }
    
    var delegate: CategoryFilterViewControllerDelegate?
    
    @IBOutlet weak var containerMultiSlider: UIView!
    @IBOutlet weak var leftSliderText: UILabel!
    @IBOutlet weak var rightSliderText: UILabel!
    
    @IBOutlet weak var voucher5: ImageSpacingBorderView!
    @IBOutlet weak var voucher10: ImageSpacingBorderView!
    @IBOutlet weak var voucher15: ImageSpacingBorderView!
    
    @IBOutlet weak var age0: RoundedLabel!
    @IBOutlet weak var age1: RoundedLabel!
    @IBOutlet weak var age2: RoundedLabel!
    @IBOutlet weak var age3: RoundedLabel!
    @IBOutlet weak var age4: RoundedLabel!
    @IBOutlet weak var age5: RoundedLabel!
    @IBOutlet weak var age6: RoundedLabel!
    @IBOutlet weak var age7: RoundedLabel!
    @IBOutlet weak var age8: RoundedLabel!
    @IBOutlet weak var age9: RoundedLabel!
    
    @IBOutlet weak var brandsContainer: UIStackView!
    
    
    var ageRangesView: [RoundedLabel] {
        get {
            [age0, age1, age2, age3, age4, age5, age6, age7, age8, age9]
        }
    }
    
    var category: Category!
    var filters: CategoryFilter!
    var maxPrice: Int!
    var productAges: [String] = []
    
    var productAgesSorted: [String] {
        get {
            productAges.sorted(by: {
                let number1 = Int($0.split(separator: " ")[0]) ?? 0
                let number2 = Int($1.split(separator: " ")[0]) ?? 0
                if $0.contains("Y") && $1.contains("Y") || $0.contains("M") && $1.contains("M"){
                    return number1 < number2
                } else if $0.contains("Y") && $1.contains("M") || $1.contains("Y") && $0.contains("M"){
                    return $0.contains("M")
                } else {
                    return $0.contains("M") || $0.contains("Y") || $1.contains("M") || $1.contains("Y")
                }
            })
        }
    }
    
    var cleanAges: [String] {
        get {
            productAgesSorted.map {
                var copy = $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let last = copy.removeLast()
                
                let newValue: String
                
                if last == "M" {
                    newValue = "\(copy)\n\("months".localise())"
                } else if last == "Y" {
                    newValue = "\(copy)\n\("years".localise())"
                } else {
                    newValue = $0
                }
                return newValue
            }
        }
    }

    lazy var multiSlider: MultiSlider = {
        let view = MultiSlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .horizontal
        view.minimumValue = 0
        view.maximumValue = CGFloat(maxPrice)
        view.value = [0,CGFloat(maxPrice)]
        view.thumbCount = 2
        view.outerTrackColor = UIColor(hex: "#9B9B9B")
        view.tintColor = UIColor(hex: "#3C9CA9")
        view.thumbImage = UIImage(named: "ic-circle")
        view.showsThumbImageShadow = false
        view.trackWidth = 3
        view.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        return view
    }()
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    var brandsDic: [String: RoundedLabel] = [:]
    var brandAll: RoundedLabel?
    
    func updateBrands() {
        let brands = self.category.brands
        
        let count = self.brandsContainer.arrangedSubviews.count
        
        
        if count == 0 {
            let view = ViewStack()
            self.brandsContainer.addArrangedSubview(view)
            brandAll = createBrandView(text: "All".localise())
            brandAll?.delegate = self
            view.addView(brandAll!)
        }
        
        self.brandAll?.isSelected = filters.brands.contains("All".localise()) || filters.brands.count == 0

        
        for (index,brand) in brands.enumerated() {
            let ligne: Int = (index + 1) / 3
            let column: Int = (index + 1) - (ligne * 3)
            
            if let stack = self.brandsContainer.arrangedSubviews.getOrNil(ligne) as? ViewStack {
                if let view = stack[column] {
                    brandsDic.removeValue(forKey: view.text ?? "")
                    view.text = brand
                    brandsDic[brand] = view
                } else {
                    brandsDic[brand] = createBrandView(text: brand)
                    stack.addView(brandsDic[brand]!)
                }
            } else {
                let stack = ViewStack()
                self.brandsContainer.addArrangedSubview(stack)
                brandsDic[brand] = createBrandView(text: brand)
                stack.addView(brandsDic[brand]!)
            }

            brandsDic[brand]!.delegate = self
            
            if self.brandAll?.isSelected ?? false {
                brandsDic[brand]!.isSelected = false
            } else {
                brandsDic[brand]!.isSelected = filters.brands.contains(brand)
            }
        }
    }
    
    func createBrandView(text: String) -> RoundedLabel {
        let view = RoundedLabel()
        view.text = text
        view.font = UIFont.helvetica(type: .medium, fontSize: 14)
        
        view.unselectedColor = UIColor(hex: "#9B9B9B")!
        view.unselectedTextColor = UIColor(hex: "#222222")!
        view.selectedTextColor = UIColor(hex: "#FFFFFF")!
        view.tintColor = UIColor(hex: "#3C9CA9")!
        view.textAlignment = .center
        
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerMultiSlider.addSubview(multiSlider)
        
        let constraints = [
            self.multiSlider.leftAnchor.constraint(equalTo: containerMultiSlider.leftAnchor, constant: 0),
            self.multiSlider.rightAnchor.constraint(equalTo: containerMultiSlider.rightAnchor, constant: 0),
            self.multiSlider.centerYAnchor.constraint(equalTo: containerMultiSlider.centerYAnchor, constant: 0),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        multiSlider.value = [
            CGFloat(self.filters.minPrice),
            CGFloat(self.filters.maxPrice == -1 ? maxPrice : self.filters.maxPrice)]
        updateSliderLabel()
        
        voucher5.isSelected = self.filters.groupDeals == .gd5
        voucher10.isSelected = self.filters.groupDeals == .gd10
        voucher15.isSelected = self.filters.groupDeals == .gd15
        
        voucher5.delegate = self
        voucher10.delegate = self
        voucher15.delegate = self
        
        
        self.ageRangesView.enumerated().forEach { (arg0) in
            let (index, view) = arg0
            
            if let value = cleanAges.getOrNil(index) {
                view.text = value
                view.isSelected = self.filters.ageRange.contains(productAgesSorted[index])
                view.delegate = self
                view.isHidden = false
            } else {
                view.isHidden = true
            }
        }

        self.updateBrands()
    }
    
    func onClicImage(view: ImageSpacingBorderView, isSelected: Bool) {
        let value: CategoryFilter.GroupDeals?
        if view == self.voucher5 {
            value = isSelected ? .gd5 : nil
        } else if view == self.voucher10 {
            value = isSelected ? .gd10 : nil
        } else if view == self.voucher15 {
            value = isSelected ? .gd15 : nil
        } else {
            return
        }
        self.filters.groupDeals = value
        
        voucher5.isSelected = value == .gd5
        voucher10.isSelected = value == .gd10
        voucher15.isSelected = value == .gd15
    }
    
    func onClicLabelAge(view: RoundedLabel, isSelected: Bool) {
        let value = self.ageRangesView.firstIndex(of: view)!
        
        let ageValue = self.productAgesSorted[value]
        if let index = self.filters.ageRange.firstIndex(of: ageValue){
            if !isSelected {
                self.filters.ageRange.remove(at: index)
            }
        } else {
            if isSelected {
                self.filters.ageRange.append(ageValue)
            }
        }
    }
    
    func onClicLabelBrandAll(view: RoundedLabel, isSelected: Bool) {
        if self.category.brands.count == 0 {
            view.isSelected = true
            self.filters.allBrands = true
            self.filters.brands = []
        } else {
            self.filters.allBrands = true
            if isSelected {
                
                self.brandsDic.values.forEach {
                    $0.isSelected = false
                }
                
                self.filters.brands = []
            } else {
                view.isSelected = true
            }
        }
    }

    
    func onClicLabel(view: RoundedLabel, isSelected: Bool) {
        if ageRangesView.contains(view) {
            self.onClicLabelAge(view: view, isSelected: isSelected)
            return
        } else if view.text == "All".localise() {
            self.onClicLabelBrandAll(view: view, isSelected: isSelected)
            return
        }
        
        guard let text = view.text, !text.isEmpty else {
            view.isSelected = false
            return
        }
        
        if isSelected {
            self.filters.allBrands = false
            self.brandAll?.isSelected = false
        }
        
        if let index = self.filters.brands.firstIndex(of: text) {
            if !isSelected {
                self.filters.brands.remove(at: index)
            }
        } else {
            if isSelected {
                self.filters.brands.append(text)
            }
        }
        
        if self.filters.brands.count == self.category.brands.count || self.filters.brands.count == 0{
            self.brandAll?.isSelected = true
            self.filters.allBrands = true
            self.filters.brands = []
            self.brandsDic.values.forEach { v in
                v.isSelected = false
            }
        }
        
    }
    
    @objc func sliderChanged(_ slider: MultiSlider) {
        updateSliderLabel()
        self.filters.minPrice = Int(multiSlider.value[0])
        self.filters.maxPrice = Int(multiSlider.value[1])
    }

    func updateSliderLabel() {
        leftSliderText.text = "\(Int(multiSlider.value[0]))€"
        rightSliderText.text = "\(Int(multiSlider.value[1]))€"
    }
    
    @IBAction func actionDiscard(_ sender: Any) {
        self.onBackPressed(sender)
    }
    
    @IBAction func actionApply(_ sender: Any) {
        self.delegate?.sort(filters: self.filters)
        self.onBackPressed(sender)
    }
    
}
