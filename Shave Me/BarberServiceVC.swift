//
//  BarberServiceVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/23/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class BarberServiceVC: MirroringViewController {

    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    weak var model: BarberServiceModel!
    var indexPath: IndexPath!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    private var hoursPicker: ActionSheetStringPicker?
    private var minutesPicker: ActionSheetStringPicker?
    
    private var selectedHoursItemPosition: Int = 0
    private var selectedMinutesItemPosition: Int = 0
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = model.name
        if model.cost > 0 {
            costTextField.text = String(describing: model.cost)
        }
        
        let hoursArray = "hoursArray".localizedArray()
        let minutesArray = "minutesArray".localizedArray()

        selectedMinutesItemPosition = 6
        selectedHoursItemPosition = 0
        if model.duration > 0 {
            let minutes = model.duration % 60
            selectedMinutesItemPosition = minutes / 5
            
            selectedHoursItemPosition = model.duration / 60
        }
        
        self.hoursLabel.text = hoursArray[selectedHoursItemPosition]
        self.minutesLabel.text = minutesArray[selectedMinutesItemPosition]
        
        self.hideKeyboardOnTap()
    }
    
    // MARK: - Click and Callback Methods

    @IBAction func onClickSelect(_ sender: UIButton) {
        guard let costStr = costTextField.text, !costStr.isEmpty, let cost = Int(costStr) else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        model.isSelected = true
        model.cost = cost
        
        let hours = selectedHoursItemPosition * 60
        let minutes = selectedMinutesItemPosition * 5
        
        model.duration = hours + minutes
        
        self.dismiss(animated: true, completion: nil)
        if let delegate = delegate {
            delegate.onViewControllerInteractionListener(interactionType: .selectServices, data: indexPath, childVC: self)
        }
    }
    
    @IBAction func onClickDeselect(_ sender: UIButton) {
        model.isSelected = false
        model.cost = 0
        model.duration = 0
        
        self.dismiss(animated: true, completion: nil)
        if let delegate = delegate {
            delegate.onViewControllerInteractionListener(interactionType: .selectServices, data: indexPath, childVC: self)
        }
    }
    
    @IBAction func onClickHoursDropdown(_ sender: UITapGestureRecognizer) {
        if hoursPicker == nil {
            let rows = "hoursArray".localizedArray()
            hoursPicker = ActionSheetStringPicker(title: "hrs".localized(), rows: rows, initialSelection: selectedHoursItemPosition, doneBlock: onHoursItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.hoursLabel)
        }
        hoursPicker?.show()
    }
    
    @IBAction func onClickMinutesDropdown(_ sender: UITapGestureRecognizer) {
        if minutesPicker == nil {
            let rows = "minutesArray".localizedArray()
            minutesPicker = ActionSheetStringPicker(title: "mins".localized(), rows: rows, initialSelection: selectedMinutesItemPosition, doneBlock: onMinutesItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.minutesLabel)
        }
        minutesPicker?.show()
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onHoursItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        hoursLabel.text = selectedValue as? String
        selectedHoursItemPosition = selectedIndex
    }
    
    func onMinutesItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        minutesLabel.text = selectedValue as? String
        selectedMinutesItemPosition = selectedIndex
    }
}
