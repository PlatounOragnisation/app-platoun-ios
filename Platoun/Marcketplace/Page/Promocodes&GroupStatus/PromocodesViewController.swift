//
//  PromocodesViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class PromocodesViewController: LightViewController {
    
    static func instance(isForPromocode: Bool) -> PromocodesViewController {
        let vc = PromocodesViewController.instanceStoryboard()
        vc.isForPromocode = isForPromocode
        return vc
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var isForPromocode = true
    
    var objs: [Any] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.beginRefreshing()
        self.tableView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
    }
    
    @objc func reload() {
        if isForPromocode {
            Interactor.shared.fetchPromocodes(userId: HttpServices.shared.userId) { (o: [PromocodeCell.Object]) in
                self.objs = o.sorted(by: { $0.dateValidated > $1.dateValidated })
            }
        } else {
            Interactor.shared.fetchGroupStatus(userId: HttpServices.shared.userId) { (o: [GroupStatusCell.Object]) in
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
        return 1 + objs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell else { return UITableViewCell() }
            cell.setup(count: objs.count)
            return cell
        }
        
        
        if isForPromocode {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PromocodeCell.identifier, for: indexPath) as? PromocodeCell else { return UITableViewCell() }
                    
            let objs:[PromocodeCell.Object] = (self.objs as! [PromocodeCell.Object])
            
            let obj = objs[indexPath.row - 1]
            cell.setup(obj)
            cell.startTimer()
            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupStatusCell.identifier, for: indexPath) as? GroupStatusCell else { return UITableViewCell() }
                    
            let objs:[GroupStatusCell.Object] = (self.objs as! [GroupStatusCell.Object])
            
            let obj = objs[indexPath.row - 1]
            cell.setup(obj)
            cell.startTimer()
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isForPromocode {
            let obj = (self.objs as! [PromocodeCell.Object])[indexPath.row - 1]
            UIPasteboard.general.string = obj.promoCodeValue
            guard let url = URL(string: obj.link) else { return }
            
            let alert = UIAlertController(title: nil, message: "The promo code has been copied to your clipboard. You will now be redirected to the merchant site.".localise(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK".localise(), style: .default, handler: { _ in
                UIApplication.shared.open(url)
            }))
            
            self.present(alert, animated: true)
        } else {
            let obj = (self.objs as! [GroupStatusCell.Object])[indexPath.row - 1]
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
        return indexPath.row == 0 ? 50 : 125
    }
}
