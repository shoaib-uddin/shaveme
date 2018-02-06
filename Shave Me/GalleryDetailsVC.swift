//
//  GalleryDetailsVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/27/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ImageSlideshow

class GalleryDetailsVC: MirroringViewController {
    
    var galleryModels: [GalleryModel]!
    var baseURL: String!
    var selectedModelIndex = 0
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSlideShow.contentScaleMode = .scaleAspectFit
        imageSlideShow.zoomEnabled = true
        
        // Loading view
        var imageSources = [AlamofireSource]()
        for model in galleryModels {
            imageSources.append(AlamofireSource(urlString: baseURL + model.imgName)!)
        }
        
        imageSlideShow.setImageInputs(imageSources)
        
        if selectedModelIndex < galleryModels.count {
            imageSlideShow.setCurrentPage(selectedModelIndex, animated: false)
        }
        
        let controller = imageSlideShow.presentFullScreenController(from: self)
        controller.closeButton.addTarget(self, action: #selector(close), for: UIControlEvents.touchUpInside)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(GalleryDetailsVC.didTap))
        imageSlideShow.addGestureRecognizer(recognizer)
    }
    
    // MARK: - Click and Callback Methods
    
    @IBAction func onClickClose(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func didTap() {
        imageSlideShow.presentFullScreenController(from: self)
    }
}
