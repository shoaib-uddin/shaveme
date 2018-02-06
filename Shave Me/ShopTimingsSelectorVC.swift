//
//  ShopTimingsSelectorVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/24/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class ShopTimingsSelectorVC: MirroringViewController {
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startAtHrsLabel: UILabel!
    @IBOutlet weak var startAtMinsLabel: UILabel!
    @IBOutlet weak var closeAtHrsLabel: UILabel!
    @IBOutlet weak var closeAtMinsLabel: UILabel!
    
    @IBOutlet weak var breakStartAtHrsLabel: UILabel!
    @IBOutlet weak var breakStartAtMinsLabel: UILabel!
    @IBOutlet weak var breakEndAtHrsLabel: UILabel!
    @IBOutlet weak var breakEndAtMinsLabel: UILabel!
    
    private static let hoursArray = "hoursArray".localizedArray()
    private static let minutesArray = "minutesArray".localizedArray()
    
    private var selectedStartAtHoursItemPosition: Int = 0
    private var selectedStartAtMinutesItemPosition: Int = 0
    private var selectedCloseAtHoursItemPosition: Int = 0
    private var selectedCloseAtMinutesItemPosition: Int = 0
    
    private var selectedBreakStartAtHoursItemPosition: Int = 0
    private var selectedBreakStartAtMinutesItemPosition: Int = 0
    private var selectedBreakEndAtHoursItemPosition: Int = 0
    private var selectedBreakEndAtMinutesItemPosition: Int = 0
    
    private var startAtHoursPicker: ActionSheetStringPicker?
    private var startAtMinutesPicker: ActionSheetStringPicker?
    private var closeAtHoursPicker: ActionSheetStringPicker?
    private var closeAtMinutesPicker: ActionSheetStringPicker?
    
    private var breakStartAtHoursPicker: ActionSheetStringPicker?
    private var breakStartAtMinutesPicker: ActionSheetStringPicker?
    private var breakCloseAtHoursPicker: ActionSheetStringPicker?
    private var breakCloseAtMinutesPicker: ActionSheetStringPicker?
    
    var model: AvailabilityModel!
    var mTitle: String?
    
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = mTitle
        
        if !model.startTime.isEmpty {
            let components = model.startTime.components(separatedBy: ":")
            
            if let index = Int(components[0]) {
                selectedStartAtHoursItemPosition = index
            }
            
            if let index = Int(components[1]) {
                selectedStartAtMinutesItemPosition = index / 5
            }
        }
        
        if !model.endTime.isEmpty {
            let components = model.endTime.components(separatedBy: ":")
            
            if let index = Int(components[0]) {
                selectedCloseAtHoursItemPosition = index
            }
            
            if let index = Int(components[1]) {
                selectedCloseAtMinutesItemPosition = index / 5
            }
        }
        
        if !model.breakStartTime.isEmpty {
            let components = model.breakStartTime.components(separatedBy: ":")
            
            if let index = Int(components[0]) {
                selectedBreakStartAtHoursItemPosition = index
            }
            
            if let index = Int(components[1]) {
                selectedBreakStartAtMinutesItemPosition = index / 5
            }
        }
        
        if !model.breakEndTime.isEmpty {
            let components = model.breakEndTime.components(separatedBy: ":")
            
            if let index = Int(components[0]) {
                selectedBreakEndAtHoursItemPosition = index
            }
            
            if let index = Int(components[1]) {
                selectedBreakEndAtMinutesItemPosition = index / 5
            }
        }
        
        self.startAtHrsLabel.text = ShopTimingsSelectorVC.hoursArray[selectedStartAtHoursItemPosition]
        self.startAtMinsLabel.text = ShopTimingsSelectorVC.minutesArray[selectedStartAtMinutesItemPosition]
        self.closeAtHrsLabel.text = ShopTimingsSelectorVC.hoursArray[selectedCloseAtHoursItemPosition]
        self.closeAtMinsLabel.text = ShopTimingsSelectorVC.minutesArray[selectedCloseAtMinutesItemPosition]
        
        self.breakStartAtHrsLabel.text = ShopTimingsSelectorVC.hoursArray[selectedBreakStartAtHoursItemPosition]
        self.breakStartAtMinsLabel.text = ShopTimingsSelectorVC.minutesArray[selectedBreakStartAtMinutesItemPosition]
        self.breakEndAtHrsLabel.text = ShopTimingsSelectorVC.hoursArray[selectedBreakEndAtHoursItemPosition]
        self.breakEndAtMinsLabel.text = ShopTimingsSelectorVC.minutesArray[selectedBreakEndAtMinutesItemPosition]
        
        AppUtils.setGestureRecognizers(senders: startAtHrsLabel, target: self, action: #selector(onClickStartAtHrs))
        AppUtils.setGestureRecognizers(senders: startAtMinsLabel, target: self, action: #selector(onClickStartAtMins))
        AppUtils.setGestureRecognizers(senders: closeAtHrsLabel, target: self, action: #selector(onClickCloseAtHrs))
        AppUtils.setGestureRecognizers(senders: closeAtMinsLabel, target: self, action: #selector(onClickCloseAtMins))
        AppUtils.setGestureRecognizers(senders: breakStartAtHrsLabel, target: self, action: #selector(onClickBreakStartAtHrs))
        AppUtils.setGestureRecognizers(senders: breakStartAtMinsLabel, target: self, action: #selector(onClickBreakStartAtMins))
        AppUtils.setGestureRecognizers(senders: breakEndAtHrsLabel, target: self, action: #selector(onClickBreakCloseAtHrs))
        AppUtils.setGestureRecognizers(senders: breakEndAtMinsLabel, target: self, action: #selector(onClickBreakCloseAtMins))
    }
    
    // MARK: - Click and Callback Methods
    
    @IBAction func onClickSetButton(_ sender: UIButton) {
        
        if (selectedStartAtHoursItemPosition == 0 && selectedStartAtMinutesItemPosition == 0) ||
            (selectedCloseAtHoursItemPosition == 0 && selectedCloseAtMinutesItemPosition == 0) {
            AppUtils.showMessage(title: "alert".localized(), message: "checkavailabilitytimings".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        if selectedCloseAtHoursItemPosition < selectedStartAtHoursItemPosition {
            AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltyclosetimeisgreater".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        if selectedCloseAtHoursItemPosition == selectedStartAtHoursItemPosition, selectedCloseAtMinutesItemPosition == selectedStartAtMinutesItemPosition {
            AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltyclosetimeisgreater".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        if selectedBreakEndAtHoursItemPosition < selectedBreakStartAtHoursItemPosition {
            AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltybreakclosetimeisgreater".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        if selectedBreakStartAtHoursItemPosition > 0, selectedBreakEndAtHoursItemPosition == selectedBreakStartAtHoursItemPosition, selectedBreakStartAtMinutesItemPosition == selectedBreakEndAtMinutesItemPosition {
            AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltybreakclosetimeisgreater".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        if selectedBreakStartAtHoursItemPosition != 0 || selectedBreakStartAtMinutesItemPosition != 0 ||
            selectedBreakEndAtHoursItemPosition != 0 || selectedBreakEndAtMinutesItemPosition != 0 {
            if selectedBreakStartAtHoursItemPosition < selectedStartAtHoursItemPosition || selectedBreakStartAtHoursItemPosition >= selectedCloseAtHoursItemPosition {
                AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltybreaktimingsbetweenshoptiming".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
            } else if selectedBreakStartAtHoursItemPosition == selectedStartAtHoursItemPosition, selectedBreakStartAtMinutesItemPosition <= selectedStartAtMinutesItemPosition {
                AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltybreaktimingsbetweenshoptiming".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
            }
            
            if selectedBreakEndAtHoursItemPosition <= selectedStartAtHoursItemPosition || selectedBreakEndAtHoursItemPosition > selectedCloseAtHoursItemPosition {
                AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltybreaktimingsbetweenshoptiming".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
            } else if selectedBreakEndAtHoursItemPosition == selectedCloseAtHoursItemPosition, selectedBreakEndAtMinutesItemPosition >= selectedCloseAtMinutesItemPosition {
                AppUtils.showMessage(title: "alert".localized(), message: "checkavailbiltybreaktimingsbetweenshoptiming".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
            }
        }
        
//        int openAtHrs = mOpenHrs.getSelectedItemPosition() - 1;
//        int openAtMinutes = (mOpenMinutes.getSelectedItemPosition() - 1) * 5;
//        int closedAtHrs = mClosedhrs.getSelectedItemPosition() - 1;
//        int closedAtMinutes = (mClosedMinutes.getSelectedItemPosition() - 1) * 5;
//        int breakopenAtHrs = mBreakStartHrs.getSelectedItemPosition() - 1;
//        int breakopenAtMinutes = (mBreakStartMinutes.getSelectedItemPosition() - 1) * 5;
//        int breakclosedAtHrs = mBreakEndhrs.getSelectedItemPosition() - 1;
//        int breakclosedAtMinutes = (mBreakEndMinutes.getSelectedItemPosition() - 1) * 5;
//        
//        availabilityModel.startTime = (openAtHrs < 10 ? ((openAtHrs == 0 && openAtMinutes == 0) ? "" : ("0" + openAtHrs + ":")) : (openAtHrs + ":"))
//            + ((openAtMinutes < 10) ?
//                ((openAtMinutes == 0 && openAtHrs == 0) ? "" : ("0" + openAtMinutes)) : openAtMinutes);
//        availabilityModel.endTime = ((closedAtHrs < 10) ?
//            ((closedAtHrs == 0 && closedAtMinutes == 0) ? "" : ("0" + closedAtHrs + ":")) : (closedAtHrs + ":"))
//            + ((closedAtMinutes < 10) ?
//                ((closedAtMinutes == 0 && closedAtHrs == 0) ? "" : ("0" + closedAtMinutes)) : closedAtMinutes);
//        availabilityModel.breakStartTime = ((breakopenAtHrs < 10) ? ((breakopenAtHrs == 0 && breakopenAtMinutes == 0) ? "" : ("0" + breakopenAtHrs + ":")) : (breakopenAtHrs + ":")) + ((breakopenAtMinutes < 10) ? ((breakopenAtMinutes == 0 && breakopenAtHrs == 0) ? "" : ("0" + breakopenAtMinutes)) : breakopenAtMinutes);
//        availabilityModel.breakEndTime = ((breakclosedAtHrs < 10) ? ((breakclosedAtHrs == 0 && breakclosedAtMinutes == 0) ? "" : ("0" + breakclosedAtHrs + ":")) : (breakclosedAtHrs + ":")) + ((breakclosedAtMinutes < 10) ? ((breakclosedAtHrs == 0 && breakclosedAtMinutes == 0) ? "" : ("0" + breakclosedAtMinutes)) : breakclosedAtMinutes);
        
        if selectedStartAtHoursItemPosition <= 0, selectedStartAtMinutesItemPosition <= 0 {
            model.startTime = ""
        } else {
            let hrs = String(format: "%02d", selectedStartAtHoursItemPosition)
            let mins = String(format: "%02d", selectedStartAtMinutesItemPosition * 5)
            
            model.startTime = hrs + ":" + mins
        }
        
        if selectedCloseAtHoursItemPosition <= 0, selectedCloseAtMinutesItemPosition <= 0 {
            model.endTime = ""
        } else {
            let hrs = String(format: "%02d", selectedCloseAtHoursItemPosition)
            let mins = String(format: "%02d", selectedCloseAtMinutesItemPosition * 5)
            
            model.endTime = hrs + ":" + mins
        }
        
        if selectedBreakStartAtHoursItemPosition <= 0, selectedBreakStartAtMinutesItemPosition <= 0 {
            model.breakStartTime = ""
        } else {
            let hrs = String(format: "%02d", selectedBreakStartAtHoursItemPosition)
            let mins = String(format: "%02d", selectedBreakStartAtMinutesItemPosition * 5)
            
            model.breakStartTime = hrs + ":" + mins
        }
        
        if selectedBreakEndAtHoursItemPosition <= 0, selectedBreakEndAtMinutesItemPosition <= 0 {
            model.breakEndTime = ""
        } else {
            let hrs = String(format: "%02d", selectedBreakEndAtHoursItemPosition)
            let mins = String(format: "%02d", selectedBreakEndAtMinutesItemPosition * 5)
            
            model.breakEndTime = hrs + ":" + mins
        }
        
        if let delegate = delegate {
            delegate.onViewControllerInteractionListener(interactionType: .reservationConfirmed, data: model, childVC: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onClickStartAtHrs() {
        if startAtHoursPicker == nil {
            let rows = "hoursArray".localizedArray()
            startAtHoursPicker = ActionSheetStringPicker(title: "hrs".localized(), rows: rows, initialSelection: selectedStartAtHoursItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.startAtHrsLabel.text = selectedValue as? String
                self.selectedStartAtHoursItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.startAtHrsLabel)
            
        }
        startAtHoursPicker?.show()
    }
    
    func onClickStartAtMins() {
        if startAtMinutesPicker == nil {
            let rows = "minutesArray".localizedArray()
            startAtMinutesPicker = ActionSheetStringPicker(title: "mins".localized(), rows: rows, initialSelection: selectedStartAtMinutesItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.startAtMinsLabel.text = selectedValue as? String
                self.selectedStartAtMinutesItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.startAtMinsLabel)
            
        }
        startAtMinutesPicker?.show()
    }
    
    func onClickCloseAtHrs() {
        if closeAtHoursPicker == nil {
            let rows = "hoursArray".localizedArray()
            closeAtHoursPicker = ActionSheetStringPicker(title: "hrs".localized(), rows: rows, initialSelection: selectedCloseAtHoursItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.closeAtHrsLabel.text = selectedValue as? String
                self.selectedCloseAtHoursItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.closeAtHrsLabel)
            
        }
        closeAtHoursPicker?.show()
    }
    
    func onClickCloseAtMins() {
        if closeAtMinutesPicker == nil {
            let rows = "minutesArray".localizedArray()
            closeAtMinutesPicker = ActionSheetStringPicker(title: "mins".localized(), rows: rows, initialSelection: selectedCloseAtMinutesItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.closeAtMinsLabel.text = selectedValue as? String
                self.selectedCloseAtMinutesItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.closeAtMinsLabel)
            
        }
        closeAtMinutesPicker?.show()
    }
    
    func onClickBreakStartAtHrs() {
        if breakStartAtHoursPicker == nil {
            let rows = "hoursArray".localizedArray()
            breakStartAtHoursPicker = ActionSheetStringPicker(title: "hrs".localized(), rows: rows, initialSelection: selectedBreakStartAtHoursItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.breakStartAtHrsLabel.text = selectedValue as? String
                self.selectedBreakStartAtHoursItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.breakStartAtHrsLabel)
            
        }
        breakStartAtHoursPicker?.show()
    }
    
    func onClickBreakStartAtMins() {
        if breakStartAtMinutesPicker == nil {
            let rows = "minutesArray".localizedArray()
            breakStartAtMinutesPicker = ActionSheetStringPicker(title: "mins".localized(), rows: rows, initialSelection: selectedBreakStartAtMinutesItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.breakStartAtMinsLabel.text = selectedValue as? String
                self.selectedBreakStartAtMinutesItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.breakStartAtMinsLabel)
            
        }
        breakStartAtMinutesPicker?.show()
    }
    
    func onClickBreakCloseAtHrs() {
        if breakCloseAtHoursPicker == nil {
            let rows = "hoursArray".localizedArray()
            breakCloseAtHoursPicker = ActionSheetStringPicker(title: "hrs".localized(), rows: rows, initialSelection: selectedBreakEndAtHoursItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.breakEndAtHrsLabel.text = selectedValue as? String
                self.selectedBreakEndAtHoursItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.breakEndAtHrsLabel)
            
        }
        breakCloseAtHoursPicker?.show()
    }
    
    func onClickBreakCloseAtMins() {
        if breakCloseAtMinutesPicker == nil {
            let rows = "minutesArray".localizedArray()
            breakCloseAtMinutesPicker = ActionSheetStringPicker(title: "mins".localized(), rows: rows, initialSelection: selectedBreakEndAtMinutesItemPosition, doneBlock: {
                (picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) in
                self.breakEndAtMinsLabel.text = selectedValue as? String
                self.selectedBreakEndAtMinutesItemPosition = selectedIndex
            }, cancel: { ActionStringCancelBlock in return }, origin: self.breakEndAtMinsLabel)
            
        }
        breakCloseAtMinutesPicker?.show()
    }
}
