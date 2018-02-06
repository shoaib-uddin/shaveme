//
//  StylistDetailVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/27/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit

class StylistDetailVC: MirroringViewController {

    var stylistModel: StylistModel!
    var baseURL: String!

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loading view
        let url = URL(string: baseURL + stylistModel.imgName)!
        self.coverImageView.af_setImage(withURL: url, placeholderImage: AppController.sharedInstance.placeHolderImage)
        self.titleLabel.text = stylistModel.name?.uppercased()
        self.descriptionLabel.text = stylistModel.description
    }

    // MARK: - Click and Callback Methods

    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
