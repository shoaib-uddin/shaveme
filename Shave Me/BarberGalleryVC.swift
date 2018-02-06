//
//  BarberGalleryVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/22/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper

class BarberGalleryVC: BaseSideMenuViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var statusLabel: UILabel!
    
    fileprivate var galleryArrayModel: GalleryArrayModel?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.revealViewController() {
            let addIconButton = UIBarButtonItem(image: #imageLiteral(resourceName: "addicon"), style: .plain, target: self, action: #selector(onClickAddImage))
            let rightBarButtonItems = [self.navigationItem.rightBarButtonItem!, addIconButton]
            
            self.navigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showProgressHUD()
        
        let barberShopID = AppController.sharedInstance.loggedInBarber?.barberShopId ?? 0
        _ = NetworkManager.getGallery(barberID: barberShopID, completionHandler: onResponse)
    }
    
    // MARK: - Click and Callback Methods

    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            if let model = Mapper<GalleryArrayModel>().map(JSONObject: response.value), model.Gallery?.count ?? 0 > 0 {
                galleryArrayModel = model
                
                self.collectionView.reloadData()
                
                statusLabel.isHidden = true
                collectionView.isHidden = false
            } else {
                statusLabel.isHidden = false
                collectionView.isHidden = true
                statusLabel.text = "noitemsfound".localized()
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    func onClickAddImage() {
        let controller = AddGalleryVC()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Collection View Delegate Methods

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let cellWidth = screenSize.width / 3.0
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.galleryArrayModel?.Gallery?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let model = self.galleryArrayModel!.Gallery![indexPath.row]
        
        
        if let imageView = cell.viewWithTag(100) as? UIImageView {
            if let baseURL = self.galleryArrayModel?.baseUrl, let url = URL(string: baseURL + model.thumbnailName) {
                imageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "smallimagefetcher"))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: - Utility Methods
}
