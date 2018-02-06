//
//  ReportItemView.swift
//  Shave Me
//
//  Created by NoorAli on 1/19/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit

class ReportItemView: UIView {
    
    @IBOutlet weak var stylistNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeView()
    }
    
    func initializeView() {
        let array = Bundle.main.loadNibNamed(ReportItemView.className, owner: self, options: nil)
        let view = array?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
}
