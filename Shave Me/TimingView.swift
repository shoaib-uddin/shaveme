//
//  TimingView.swift
//  Shave Me
//
//  Created by NoorAli on 1/24/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import M13Checkbox

class TimingView: UIView, ViewControllerInterationProtocol {
    static let WEEK_ARRAY = ["sunday".localized(), "monday".localized(), "tuesday".localized(), "wednesday".localized(), "thursday".localized(), "friday".localized(), "saturday".localized()]
    let DAY_CHECKBOX_PARENT_TAG = 9, DAY_CHECKBOX_TAG = 10, DAY_CHECKBOX_LABEL_TAG = 11
    let START_AT_LABEL_TAG = 12, CLOSED_AT_LABEL_TAG = 13, BREAK_START_AT_LABEL_TAG = 14, BREAK_END_AT_LABEL_TAG = 15
    
    @IBOutlet weak var sameTimingCheckbox: M13Checkbox!
    
    weak var viewController: UIViewController!
    var originalAvailabilityModel = [AvailabilityModel]()
    
    // MARK: - Life Cycle Methods

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeView()
    }
    
    // MARK: - Click and Callback Methods

    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if let model = data as? AvailabilityModel {
            if let originalModel = AvailabilityModel.getModel(models: originalAvailabilityModel, day: model.day) {
                originalModel.startTime = model.startTime
                originalModel.endTime = model.endTime
                originalModel.breakStartTime = model.breakStartTime
                originalModel.breakEndTime = model.breakEndTime
            } else {
                originalAvailabilityModel.append(model)
            }
            
            loadTimingsView()
        }
    }
    
    func onClickCellView(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view, cell.tag > 0 {
            // Tag ranges from 1-7
            let position = cell.tag
            
            if let model = AvailabilityModel.getModel(models: originalAvailabilityModel, day: position) {
                let controller = ShopTimingsSelectorVC()
                controller.model = model
                controller.delegate = self
                controller.mTitle = TimingView.WEEK_ARRAY[position - 1]
                AppUtils.addViewControllerModally(originVC: viewController, destinationVC: controller, widthMultiplier: 0.95, HeightMultiplier: 0.6)
            } else {
                showTimingSelector(position: position)
            }
        }
    }
    
    func onClickDayCheckboxContainer(_ sender: UITapGestureRecognizer) {
        if let checkbox = sender.view?.viewWithTag(DAY_CHECKBOX_TAG) as? M13Checkbox, let cell = sender.view?.superview, cell.tag > 0 {
            // Tag ranges from 1-7
            let position = cell.tag
            
            if checkbox.checkState == .checked {
                let alert = UIAlertController(title: "alert".localized(), message: "removeavailability".localized(), preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "yes".localized(), style: .default, handler: { _ in
                    if let index = AvailabilityModel.indexOfModel(models: self.originalAvailabilityModel, day: position) {
                        self.originalAvailabilityModel.remove(at: index)
                        
                        self.loadTimingsView()
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "no".localized(), style: .default, handler: nil))
                
                viewController.present(alert, animated: true, completion: nil)
            } else {
                showTimingSelector(position: position)
            }
        }
    }
    
    @IBAction func onClickTimingsSameForAllDays(_ sender: UITapGestureRecognizer) {
        if sameTimingCheckbox.checkState == .unchecked {
            let alert = UIAlertController(title: "alert".localized(), message: "setTimingsForAllDays".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "yes".localized(), style: .default, handler: { _ in
                self.sameTimingCheckbox.checkState = self.sameTimingCheckbox.checkState == .checked ? .unchecked : .checked
                
                if let model = AvailabilityModel.getModel(models: self.originalAvailabilityModel, day: 1) {
                    for item in self.originalAvailabilityModel {
                        item.startTime = model.startTime
                        item.endTime = model.endTime
                        item.breakStartTime = model.breakStartTime
                        item.breakEndTime = model.breakEndTime
                    }
                    
                    self.loadTimingsView()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "no".localized(), style: .default, handler: nil))
            
            viewController.present(alert, animated: true, completion: nil)
        } else {
            self.sameTimingCheckbox.checkState = .unchecked
        }
    }
    
    // MARK: - Utility Methods

    func showTimingSelector(position: Int) {
        var startTime = ""
        var endTime = ""
        var breakStartTime = ""
        var breakEndTime = ""
        
        if sameTimingCheckbox.checkState == .checked, let model = AvailabilityModel.getInitialAvailabilityModel(models: originalAvailabilityModel, day: 1) {
            startTime = model.startTime
            endTime = model.endTime
            breakStartTime = model.breakStartTime
            breakEndTime = model.breakEndTime
        }
        
        let model = AvailabilityModel(day: position, startTime: startTime, endTime: endTime, breakStartTime: breakStartTime, breakEndTime: breakEndTime)
        
        if originalAvailabilityModel.count == 0 || sameTimingCheckbox.checkState == .unchecked {
            let controller = ShopTimingsSelectorVC()
            controller.delegate = self
            controller.model = model
            controller.mTitle = TimingView.WEEK_ARRAY[position - 1]
            AppUtils.addViewControllerModally(originVC: viewController, destinationVC: controller, widthMultiplier: 0.95, HeightMultiplier: 0.6)
        } else {
            originalAvailabilityModel.append(model)
            loadTimingsView()
        }
    }
    
    func initializeView() {
        let array = Bundle.main.loadNibNamed(TimingView.className, owner: self, options: nil)
        let view = array?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func loadModel(availability: [AvailabilityModel]) {
        originalAvailabilityModel = availability
        
        loadTimingsView()
    }
    
    func loadTimingsView() {
        for (index, element) in TimingView.WEEK_ARRAY.enumerated() {
            if let view = self.viewWithTag(index+1) {
                if let checkboxLabel = view.viewWithTag(DAY_CHECKBOX_LABEL_TAG) as? UILabel {
                    checkboxLabel.text = element
                }
                
                var startAt = "--:--", closeAt = "--:--", breakStartAt = "--:--", breakEndAt = "--:--"
                var checkState = false.getCheckState()
                
                if let model = AvailabilityModel.getModel(models: originalAvailabilityModel, day: index+1) {
                    startAt = model.startTime.isEmpty ? startAt : model.startTime
                    closeAt = model.endTime.isEmpty ? closeAt : model.endTime
                    breakStartAt = model.breakStartTime.isEmpty ? breakStartAt : model.breakStartTime
                    breakEndAt = model.breakEndTime.isEmpty ? breakEndAt : model.breakEndTime
                    checkState = .checked
                }
                
                
                if let checkbox = view.viewWithTag(DAY_CHECKBOX_TAG) as? M13Checkbox {
                    checkbox.checkState = checkState
                }
                
                if let label = view.viewWithTag(START_AT_LABEL_TAG) as? UILabel {
                    label.text = startAt
                }
                
                if let label = view.viewWithTag(CLOSED_AT_LABEL_TAG) as? UILabel {
                    label.text = closeAt
                }
                
                if let label = view.viewWithTag(BREAK_START_AT_LABEL_TAG) as? UILabel {
                    label.text = breakStartAt
                }
                
                if let label = view.viewWithTag(BREAK_END_AT_LABEL_TAG) as? UILabel {
                    label.text = breakEndAt
                }
                
                // Mapping click callbacks
                if let checkboxContainer = view.viewWithTag(DAY_CHECKBOX_PARENT_TAG) {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickDayCheckboxContainer(_:)))
                    tapGesture.numberOfTapsRequired = 1
                    checkboxContainer.addGestureRecognizer(tapGesture)
                }
                
                // Mapping click callbacks
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickCellView(_:)))
                tapGesture.numberOfTapsRequired = 1
                view.addGestureRecognizer(tapGesture)
            }
        }
    }
}
