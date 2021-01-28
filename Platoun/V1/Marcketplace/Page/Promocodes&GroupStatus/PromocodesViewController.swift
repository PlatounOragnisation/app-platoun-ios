//
//  PromocodesViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class PromocodesViewController: LightViewController {
    
    static func instance(isForPromocode: Bool) -> PromocodesViewController {
        let vc = PromocodesViewController.instanceStoryboard()
        vc.isForPromocode = isForPromocode
        return vc
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var isForPromocode = true
    
    var objs: [Any] = [] {
        didSet {
            
            DispatchQueue.main.async {
                self.updateResultLabel()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func updateResultLabel() {
        let text: String
        if self.objs.count > 1 {
            text = "Results: %d items"
        } else {
            text = "Results: %d item"
        }
        self.resultLabel.text = text.localise(self.objs.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateResultLabel()
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.beginRefreshing()
        self.tableView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
    }
    
    @objc func reload() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        if isForPromocode {
            Interactor.shared.fetchPromocodes(userId: userId) { (o: [PromocodeCell.Object]) in
                self.objs = o.sorted(by: { $0.dateValidated > $1.dateValidated })
            }
        } else {
            Interactor.shared.fetchGroupStatus(userId: userId) { (o: [GroupStatusCell.Object]) in
                self.objs = o.sorted(by: { $0.dateAdded > $1.dateAdded })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = self.isForPromocode ? "Promocodes".localise(): "Group Status".localise()
        
        self.reload()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PromocodesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if
            isForPromocode,
            let cell = tableView.dequeueReusableCell(withIdentifier: PromocodeCell.identifier, for: indexPath) as? PromocodeCell,
            let objs = self.objs as? [PromocodeCell.Object],
            objs.count > indexPath.row
            {
            
            let obj = objs[indexPath.row]
            cell.setup(obj)
            cell.startTimer()
            return cell
        } else if
            !isForPromocode,
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupStatusCell.identifier, for: indexPath) as? GroupStatusCell,
            let objs = self.objs as? [GroupStatusCell.Object],
            objs.count > indexPath.row
            {
            let obj = objs[indexPath.row]
            cell.setup(obj)
            cell.startTimer()
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            isForPromocode,
            let objs = self.objs as? [PromocodeCell.Object],
            objs.count > indexPath.row
            {
            let obj = objs[indexPath.row]
            UIPasteboard.general.string = obj.promoCodeValue
            guard let url = URL(string: obj.link) else { return }
            
            let alert = UIAlertController(title: nil, message: "The promo code has been copied to your clipboard. You will now be redirected to the merchant site.".localise(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK".localise(), style: .default, handler: { _ in
                UIApplication.shared.open(url)
            }))
            
            self.present(alert, animated: true)
        } else if
            let objs = self.objs as? [GroupStatusCell.Object],
            objs.count > indexPath.row
        {
            let obj = objs[indexPath.row]
            if obj.state == .success {
                let promocode = obj.promoCodeValue
                let link = obj.link
                let vc = SuccessViewController.instance(promocode: promocode, link: link)
                
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                return
            } else if let productId = obj.productId {
                let vc = ProductViewController.instance(productId: productId)
                self.navigationController?.show(vc, sender: nil)
                return
            } else {
                return
            }
        }
    }
}

extension PromocodesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
