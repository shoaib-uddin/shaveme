//
//  PriceListVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/27/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit

class PriceListVC: MirroringViewController, UITableViewDataSource, UITableViewDelegate {
    
    var serviceModels: [ServiceModel]!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Click and Callback Methods
    
    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Tableview Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serviceModels?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PriceCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! PriceCell
        let model = self.serviceModels![indexPath.row]
        
        cell.nameLabel.text = model.name.uppercased()
        cell.priceLabel.text = String(model.cost) + " " + "aed".localized()
        cell.durationLabel.text = "duration".localized() + " " + String(model.duration) + " " + "minutes".localized()
        
        return cell
    }
}

class PriceCell: UITableViewCell {
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var priceLabel : UILabel!
    @IBOutlet weak var durationLabel : UILabel!
}
