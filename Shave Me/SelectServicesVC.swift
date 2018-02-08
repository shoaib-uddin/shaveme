//
//  SelectServicesVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/28/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import M13Checkbox

class SelectServicesVC: MirroringViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    var interactionType = VCInterationType.selectServices
    
    var originalListItems: [ListItem]!
    private var currentListItems: [ListItem]!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentListItems = originalListItems.sorted(by: { (a, b) -> Bool in
            return a.name < b.name;
        })
        
        // Changing navigation bar color
        if let navigationController = self.navigationController {
            navigationController.navigationBar.barTintColor = UIColor.COLcdcdcd()
        }

        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(SelectServicesVC.onClickDone(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
        let resetButton = UIBarButtonItem(title: "reset".localized(), style: .plain, target: self, action: #selector(SelectServicesVC.onClickReset(_:)))
        self.navigationItem.leftBarButtonItem = resetButton
        
        self.tableView.reloadData()
    }

    // MARK: - Search Bar Delegate Methods
    
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
        
        let cell:CheckboxCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! CheckboxCell
        let model = self.currentListItems![indexPath.row]
        
        cell.titleLabel.text = model.name
        cell.checkBox.setCheckState(model.isSelected ? .checked : .unchecked, animated: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let currentCell = tableView.cellForRow(at: indexPath) as! CheckboxCell
        let model = self.currentListItems![indexPath.row]

        model.isSelected = !model.isSelected
        currentCell.checkBox.checkState = model.isSelected ? .checked : .unchecked
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

class CheckboxCell: UITableViewCell {
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var checkBox: M13Checkbox!
}

class ListItem {
    var name: String = ""
    var id: Int = 0
    var isSelected = false
    var associatedFacilitiesId: Int?
    
    init(name: String, id: Int, isSelected: Bool = false) {
        self.name = name
        self.id = id
        self.isSelected = isSelected
    }
    
    init(name: String, id: Int, associatedFacilitiesId: Int?, isSelected: Bool = false) {
        self.name = name
        self.id = id
        self.isSelected = isSelected
        self.associatedFacilitiesId = associatedFacilitiesId
    }
    
    class func getModel(models: [ListItem]?, id: Int?) -> ListItem? {
        if let models = models, let id = id {
            for model in models {
                if model.id == id {
                    return model
                }
            }
        }
        return nil
    }
}
