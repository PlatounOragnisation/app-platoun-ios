//
//  ProfilV2ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 06/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

class ProfilV2ViewController: UIViewController {
    
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var suggestionCountLabel: UILabel!
    @IBOutlet weak var suggestionTitleLabel: UILabel!
    
    @IBOutlet weak var votesCountLabel: StyleLabel!
    @IBOutlet weak var votesTitleLabel: StyleLabel!
    
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var suggestionLine: UIImageView!
    @IBOutlet weak var swipeStarLabel: UILabel!
    @IBOutlet weak var swipeStarLine: UIImageView!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var votesLine: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.initPlatounTheme(isTransparent: true)
        self.navigationItem.initTitleItem()

        profilImageView.layer.cornerRadius = 16
        profilImageView.layer.masksToBounds = true
        
        votesCountLabel.update(colors: [ThemeColor.cFFE600, ThemeColor.cFFC7C7])
        votesTitleLabel.update(colors: [ThemeColor.cFFE600, ThemeColor.cFFC7C7])
    }
    
    var user: UserV2!
    var products: [ProductV2] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.roundCorners(corners: [ .topLeft, .topRight], radius: 16.0)
        tableView.delegate = self
        tableView.dataSource = self
        
        seed(self)
        initializeUser()
        initializeCollectionView()
    }
    
    
    func initializeUser() {
        userNameLabel.text = "@\(user.name)"
        suggestionCountLabel.text = user.suggestionCount.concat()
        suggestionTitleLabel.text = user.suggestionCount > 1 ? "suggestions" : "suggestion"
        votesCountLabel.text = user.votesCount.concat()
        votesTitleLabel.text = user.votesCount > 1 ? "votes" : "vote"
        profilImageView.setImage(with: URL(string: user.profilPictureUrl)!, placeholder: nil, options: .progressiveLoad)
    }
    
    func initializeCollectionView() {
        self.tableView.reloadData()
    }
    
    @IBAction func sugestionActionTap(_ sender: Any) {
        suggestionLabel.textColor = ThemeColor.c01C7AD
        suggestionLine.image = UIImage(named: "img-bottom-ligne-select")
        swipeStarLabel.textColor = ThemeColor.cB8B8B8
        swipeStarLine.image = UIImage(named: "img-bottom-ligne-unselect")
        votesLabel.textColor = ThemeColor.cB8B8B8
        votesLine.image = UIImage(named: "img-bottom-ligne-unselect")
        
        
    }
    
    @IBAction func swipeStarActionTap(_ sender: Any) {
        suggestionLabel.textColor = ThemeColor.cB8B8B8
        suggestionLine.image = UIImage(named: "img-bottom-ligne-unselect")
        swipeStarLabel.textColor = ThemeColor.c01C7AD
        swipeStarLine.image = UIImage(named: "img-bottom-ligne-select")
        votesLabel.textColor = ThemeColor.cB8B8B8
        votesLine.image = UIImage(named: "img-bottom-ligne-unselect")
        
    }
    
    @IBAction func votesActionTap(_ sender: Any) {
        suggestionLabel.textColor = ThemeColor.cB8B8B8
        suggestionLine.image = UIImage(named: "img-bottom-ligne-unselect")
        swipeStarLabel.textColor = ThemeColor.cB8B8B8
        swipeStarLine.image = UIImage(named: "img-bottom-ligne-unselect")
        votesLabel.textColor = ThemeColor.c01C7AD
        votesLine.image = UIImage(named: "img-bottom-ligne-select")
        
    }
    
}

extension ProfilV2ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (self.products.count / 3) + (self.products.count % 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.row % 2 == 0 ? ThreeProductCell.Odd : ThreeProductCell.Even
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ThreeProductCell else { return UITableViewCell() }

        cell.setup(
            product1: self.products.getOrNil(indexPath.row*3),
            product2: self.products.getOrNil(indexPath.row*3+1),
            product3: self.products.getOrNil(indexPath.row*3+2),
            index: indexPath.row)
        
        cell.productClosure = { product in
            
        }
        
        return cell
    }
    
    @IBAction func takePictureActionTap(_ sender: Any) {
        takePictureForPost(in: self)
    }
}

extension ProfilV2ViewController: UITableViewDelegate {
    
}

extension Int {
    func concat() -> String {
        if self >= 1000000 {
            let result = Double(self)/1000000.0
            return String(format: "%.1f", result)+"M"
        } else if self >= 1000 {
            let result = Double(self)/1000.0
            return String(format: "%.1f", result)+"K"
        } else {
            return "\(self)"
        }
    }
}


func seed(_ vc: ProfilV2ViewController) {
    vc.user = UserV2(
        name: "Gustave45",
        profilPictureUrl: "https://www.nicesnippets.com/demo/profile-3.jpg",
        suggestionCount: 821,
        votesCount: 10200
    )
    
    vc.products =
    [
        ProductV2(id: "", productName: "",
                  productImage: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://offautan-uc1.azureedge.net/-/media/images/off/ph/products-en/products-landing/landing/off_overtime_product_collections_large_2x.jpg?la=en-ph",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://offautan-uc1.azureedge.net/-/media/images/off/ph/products-en/products-landing/landing/off_overtime_product_collections_large_2x.jpg?la=en-ph",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://offautan-uc1.azureedge.net/-/media/images/off/ph/products-en/products-landing/landing/off_overtime_product_collections_large_2x.jpg?la=en-ph",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg",
                  productComment: "", userName: "", userImage: "", userId: ""),
        ProductV2(id: "", productName: "",
                  productImage: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg",
                  productComment: "", userName: "", userImage: "", userId: "")
    ]
}
