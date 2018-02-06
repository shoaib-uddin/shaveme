//
//  AddBarberServicesVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/23/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import M13Checkbox

class AddBarberServicesVC: MirroringViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ViewControllerInterationProtocol {
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    var interactionType = VCInterationType.selectServices
    
    var originalListItems: [BarberServiceModel]!
    private var currentListItems: [BarberServiceModel]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentListItems = originalListItems
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Changing navigation bar color
        if let navigationController = self.navigationController {
            navigationController.navigationBar.barTintColor = UIColor.COLcdcdcd()
        }
        
        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(SelectServicesVC.onClickDone(_:)))
        self.navigationItem.leftBarButtonItem = doneButton
        
        let resetButton = UIBarButtonItem(title: "reset".localized(), style: .plain, target: self, action: #selector(SelectServicesVC.onClickReset(_:)))
        self.navigationItem.rightBarButtonItem = resetButton
        
        self.tableView.reloadData()
    }
    
    // MARK: - Search Bar Delegate Methods
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .selectServices, let indexPath = data as? IndexPath, let model = self.currentListItems?[indexPath.row] {
            let currentCell = tableView.cellForRow(at: indexPath) as! BarberServiceCell
        
            currentCell.checkBox.checkState = model.isSelected ? .checked : .unchecked
            
            currentCell.highConstraint.constant = model.isSelected ? 30 : 0
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            currentListItems = originalListItems
        } else {
            currentListItems = []
            originalListItems.forEach({ (item) in
                if item.name.lowercased().contains(searchText.lowercased()) {
                    currentListItems.append(item)
                }
            })
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Tableview Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentListItems?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:BarberServiceCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! BarberServiceCell
        let model = self.currentListItems![indexPath.row]
        
        cell.titleLabel.text = model.name
        cell.checkBox.setCheckState(model.isSelected ? .checked : .unchecked, animated: false)
        cell.totalCostLabel.text = "cost".localized() + String(describing: model.cost)
        cell.totalDurationLabel.text = "duration_text".localized() + String(describing: model.duration)
        
        cell.highConstraint.constant = model.isSelected ? 30 : 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = self.currentListItems![indexPath.row]
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: BarberServiceVC.storyBoardID) as! BarberServiceVC
        controller.delegate = self
        controller.model = model
        controller.indexPath = indexPath
        let navController = UINavigationController(rootViewController: controller)
        AppUtils.addViewControllerModally(originVC: self, destinationVC: navController, widthMultiplier: 0.95, HeightMultiplier: 0.6)
    }
    
    // MARK: - Click and Callback Methods
    
    func onClickDone(_ sender: Any?) {
        if let delegate = self.delegate {
            delegate.onViewControllerInteractionListener(interactionType: interactionType, data: originalListItems, childVC: self)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func onClickReset(_ sender: Any?) {
        currentListItems.forEach { $0.isSelected = false }
        self.tableView.reloadData()
    }
}

class BarberServiceCell: UITableViewCell {
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var checkBox: M13Checkbox!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var extraContentView: UIView!
    @IBOutlet weak var highConstraint: NSLayoutConstraint!
}

class BarberServiceModel {
    var name: String = ""
    var serviceId: Int = 0
    var cost: Int = 0
    var duration: Int = 0
    var isSelected = false
    var associatedServicesId: Int?
    
    init(name: String, serviceId: Int, isSelected: Bool = false) {
        self.name = name
        self.serviceId = serviceId
        self.isSelected = isSelected
    }
    
    func setServiceModel(model: ServiceModel) {
        self.associatedServicesId = model.associatedServicesId
        self.isSelected = true
        self.cost = model.cost
        self.duration = model.duration
    }
}
