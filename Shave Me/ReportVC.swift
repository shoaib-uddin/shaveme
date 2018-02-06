//
//  ReportVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/19/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class ReportVC: BaseSideMenuViewController, ViewControllerInterationProtocol {

    fileprivate static let FILTER_STATUS_ARRAY = [ListItem(name: "confirmed".localized(), id: AppoinmentModel.APPOINMENT_CONFIRMED),
                                                  ListItem(name: "pending".localized(), id: AppoinmentModel.APPOINMENT_PENDING),
                                                  ListItem(name: "cancelled".localized(), id: AppoinmentModel.APPOINMENT_CANCELLED_BY_USER),
                                                  ListItem(name: "completed".localized(), id: AppoinmentModel.APPOINMENT_COMPLETED),
                                                  ListItem(name: "notAttend".localized(), id: AppoinmentModel.APPOINMENT_CONFIRMED_NOT_ATTEND),
                                                  ListItem(name: "auto_cancel".localized(), id: AppoinmentModel.APPOINMENT_AUTO_CANCELLED)]
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var selectedFilterStylistsLabel: UILabel!
    @IBOutlet weak var selectedFilterStatusLabel: UILabel!
    
    private var selectedStylists = [Int : StylistModel]()
    private var selectedStatus = [Int : ListItem]()
    
    fileprivate var startSelectedDate = Date()
    fileprivate var endSelectedDate = Date().nextDay
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "report".localized()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    
    // MARK: - Click and Callback Methods
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .selectStylist {
            onStylistsSelectionChange(data: data)
        } else if interactionType == .selectReportStatus {
            onReportStatusSelectionChange(data: data)
        }
    }
    
    @IBAction func onClickStartDate(_ sender: Any) {
        let title = "startdate".localized()
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.date, selectedDate: startSelectedDate, doneBlock: {
            picker, value, index in
            self.startSelectedDate = value as! Date
            
            self.startDateLabel.text = self.startSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        }, cancel: { ActionStringCancelBlock in return }, origin: self.startDateLabel)
    
        datePicker?.show()
    }
    
    @IBAction func onClickEndDate(_ sender: Any) {
        guard "startdate".localized() != self.startDateLabel.text else {
            AppUtils.showMessage(title: "alert".localized(), message: "ReportChcekstartDate".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        let title = "enddate".localized()
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.date, selectedDate: endSelectedDate, doneBlock: {
            picker, value, index in
            guard let value = value as? Date, self.startSelectedDate.isBefore(to: value) else {
                AppUtils.showMessage(title: "alert".localized(), message: "dateValidation".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
            }
            
            self.endSelectedDate = value
            
            self.endDateLabel.text = self.endSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        }, cancel: { ActionStringCancelBlock in return }, origin: self.startDateLabel)
        
        datePicker?.show()
    }
    
    @IBAction func onClickFilterStylistButton(_ sender: UIButton) {
        guard let stylistArray = AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist else {
            return
        }
        
        var itemListArray: [ListItem] = [ListItem]()
        
        for model in stylistArray {
            if let name = model.name, !name.isEmpty, let id = model.stylistId {
                let isFound = selectedStylists[id] != nil
                itemListArray.append(ListItem(name: name, id: id, isSelected: isFound))
            }
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: SelectServicesVC.storyBoardID) as! SelectServicesVC
        controller.originalListItems = itemListArray
        controller.delegate = self
        controller.interactionType = .selectStylist
        controller.title = "filterServices".localized()
        let navController = UINavigationController(rootViewController: controller)
        AppUtils.addViewControllerModally(originVC: self, destinationVC: navController, widthMultiplier: 0.9, HeightMultiplier: 0.8)
    }
    
    @IBAction func onClickFilterStatusButton(_ sender: UIButton) {
        var itemListArray: [ListItem] = [ListItem]()
        
        for model in ReportVC.FILTER_STATUS_ARRAY {
            let isFound = selectedStatus[model.id] != nil
            itemListArray.append(ListItem(name: model.name, id: model.id, isSelected: isFound))
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: SelectServicesVC.storyBoardID) as! SelectServicesVC
        controller.originalListItems = itemListArray
        controller.delegate = self
        controller.interactionType = .selectReportStatus
        controller.title = "filterStatus".localized()
        let navController = UINavigationController(rootViewController: controller)
        AppUtils.addViewControllerModally(originVC: self, destinationVC: navController, widthMultiplier: 0.9, HeightMultiplier: 0.8)
    }
    
    @IBAction func onClickGenerateReportButton(_ sender: UIButton) {
        guard "startdate".localized() != self.startDateLabel.text, "enddate".localized() != self.endDateLabel.text else {
            AppUtils.showMessage(title: "alert".localized(), message: "reportemptydate".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }

        let stylistIDs = selectedStylists.values.map({ return String($0.stylistId!) }).joined(separator: ",")
        let statusIDs = selectedStatus.values.map({ return String($0.id) }).joined(separator: ",")
        
        let controller = ReportResultVC()
        controller.startDate = startSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        controller.endDate = endSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        controller.stylistIDs = stylistIDs
        controller.statusIDs = statusIDs
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onStylistsSelectionChange(data: Any?) {
        guard let stylistArray = AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist, let itemList = data as? [ListItem] else {
            return
        }
        
        var formattedList = ""
        for item in itemList {
            if item.isSelected {
                if selectedStylists[item.id] == nil, let model = StylistModel.getModel(models: stylistArray, id: item.id) {
                    selectedStylists[item.id] = model
                }
            } else {
                selectedStylists[item.id] = nil
            }
        }
        
        formattedList = itemList.flatMap({ $0.isSelected ? "\($0.name)" : nil }).joined(separator: ", ")
        
        selectedFilterStylistsLabel.text = formattedList
        selectedFilterStylistsLabel.superview?.isHidden = formattedList.isEmpty
    }
    
    func onReportStatusSelectionChange(data: Any?) {
        guard let itemList = data as? [ListItem] else {
            return
        }
        
        var formattedList = ""
        for item in itemList {
            if item.isSelected {
                if selectedStatus[item.id] == nil, let model = ListItem.getModel(models: ReportVC.FILTER_STATUS_ARRAY, id: item.id) {
                    selectedStatus[item.id] = model
                }
            } else {
                selectedStatus[item.id] = nil
            }
        }
        
        formattedList = itemList.flatMap({ $0.isSelected ? "\($0.name)" : nil }).joined(separator: ", ")
        
        selectedFilterStatusLabel.text = formattedList
        selectedFilterStatusLabel.superview?.isHidden = formattedList.isEmpty
    }
}








