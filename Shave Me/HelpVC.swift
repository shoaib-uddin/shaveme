//
//  HelpVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/8/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ImageSlideshow


class HelpVC: MirroringViewController {

    var INTRO_SCREENS_EN = [#imageLiteral(resourceName: "intro1"), #imageLiteral(resourceName: "intro2"), #imageLiteral(resourceName: "intro3")]
    var INTRO_SCREENS_AR = [#imageLiteral(resourceName: "intro1_ar"), #imageLiteral(resourceName: "intro2_ar"), #imageLiteral(resourceName: "intro3_ar")]
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    @IBOutlet weak var doneSkipButton: UIButton!
    
<<<<<<< HEAD
=======
    @IBOutlet weak var videoView: UIView!
    
    
    var avPlayer: AVPlayer!;
    var avPlayerLayer: AVPlayerLayer!
    
>>>>>>> parent of aa71e95... All done leaving minor bugs behind
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

<<<<<<< HEAD
        
=======
>>>>>>> parent of aa71e95... All done leaving minor bugs behind
        imageSlideShow.circular = false
        
        let selectedImages = AppController.sharedInstance.language == "en" ? INTRO_SCREENS_EN : INTRO_SCREENS_AR
        let imageSources = selectedImages.map { return ImageSource(image: $0) }
        imageSlideShow.setImageInputs(imageSources)
        
        imageSlideShow.contentScaleMode = .scaleAspectFill
        
        doneSkipButton.isHidden = !MyUserDefaults.getShowHelpScreen()
        
        imageSlideShow.currentPageChanged = { currentPage in
            self.doneSkipButton.isHidden = true
            
            if currentPage == 2 {
                self.doneSkipButton.setTitle("done".localized(), for: .normal)
                self.doneSkipButton.isHidden = false
            }
        }
        
        
        
        
    }
    
<<<<<<< HEAD
    
    
    
    
=======
    @IBAction func xVideo(_ sender: UIButton) {
        avPlayer.pause();
        avPlayer = nil;
        self.videoView.removeFromSuperview();
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        avPlayerLayer.frame = view.bounds
        
        
        
        
    }
>>>>>>> parent of aa71e95... All done leaving minor bugs behind
    
    
    
    
    // Force the view into landscape mode (which is how most video media is consumed.)
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscape
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true);
<<<<<<< HEAD
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        let destination = storyboard.instantiateViewController(withIdentifier: "AVPlayerVC") as! AVPlayerVC
        self.navigationController?.present(destination, animated: false, completion: nil);
        
=======
        avPlayerLayer.frame = videoView.bounds;
        avPlayerLayer.transform = CATransform3DMakeRotation(CGFloat(90.0 / 180.0 * .pi), 0.0, 0.0, 1.0);
        avPlayer.play() // Start the playback
>>>>>>> parent of aa71e95... All done leaving minor bugs behind
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Click and Callback Methods

    @IBAction func onClickDoneSkip(_ sender: Any) {
        MyUserDefaults.getDefaults().set(false, forKey: MyUserDefaults.PREFS_SHOW_HELP)
        _ = self.navigationController?.popViewController(animated: false)
    }
<<<<<<< HEAD
    
    
=======
>>>>>>> parent of aa71e95... All done leaving minor bugs behind
}
