//
//  SplitColumnView.swift
//  Shave Me
//
//  Created by NoorAli on 12/26/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit

class SplitColumnView: UIView {

    let TEXT_LENGTH = 20
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var secondServiceView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeView()
    }
    
    func initializeView() {
        let view = Bundle.main.loadNibNamed(SplitColumnView.className, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func setFirstLabel(text: String) {
//        if text.characters.count > TEXT_LENGTH {
//            self.firstLabel.text = text.trunc(length: TEXT_LENGTH) + "..."
//        } else {
            self.firstLabel.text = text
//        }
    }
    
    func setSecondLabel(text: String) {
//        if text.characters.count > TEXT_LENGTH {
//            self.secondLabel.text = text.trunc(length: TEXT_LENGTH) + "..."
//        } else {
            self.secondLabel.text = text
//        }
    }
}
