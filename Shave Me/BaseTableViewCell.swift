//
//  BaseTableViewCell.swift
//  Shave Me
//
//  Created by NoorAli on 12/20/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    weak var delegate: TableViewCellProtocol? = nil
    var cellIndex: IndexPath?
    var data: Any?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        UIView.applyStrings(view: self.contentView)   
    }
    
    // Connect this method in your class
    func onClickCallback(_ sender: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.didClickOnCell(indexPath: cellIndex!, cell: self, data: data, sender: sender.view!)
        }
    }
    
    func setGestureRecognizer(senders: UIView ...) {
        for sender in senders {
            let tapGesture = UITapGestureRecognizer(target: self, action:#selector(BaseTableViewCell.onClickCallback(_:)))
            tapGesture.numberOfTapsRequired = 1
            sender.addGestureRecognizer(tapGesture)
        }
    }
    
    func setCustomDelegateCallback(delegate: TableViewCellProtocol, cellIndex: IndexPath, data: Any?) {
        self.delegate = delegate
        self.cellIndex = cellIndex
        self.data = data
    }
}
