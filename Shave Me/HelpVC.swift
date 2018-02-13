//
//  HelpVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/8/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ImageSlideshow
import AVFoundation

class HelpVC: MirroringViewController {

    var INTRO_SCREENS_EN = [#imageLiteral(resourceName: "intro1"), #imageLiteral(resourceName: "intro2"), #imageLiteral(resourceName: "intro3")]
    var INTRO_SCREENS_AR = [#imageLiteral(resourceName: "intro1_ar"), #imageLiteral(resourceName: "intro2_ar"), #imageLiteral(resourceName: "intro3_ar")]
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    @IBOutlet weak var doneSkipButton: UIButton!
    
    @IBOutlet weak var videoView: UIView!
    
    
    
    var avPlayer: AVPlayer!;
    var avPlayerLayer: AVPlayerLayer!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        let appDelegate =  AppDelegate.getAppDelegate();
        appDelegate.shouldRotate = true;
        
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
        
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        avPlayer = AVPlayer();
        avPlayerLayer = AVPlayerLayer(player: avPlayer);
        
        
        self.videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        let path = Bundle.main.path(forResource: "video", ofType: "mp4");
        //let url = NSURL(string: path!);
        let playerItem = AVPlayerItem.init(url: URL(fileURLWithPath: path!));
        avPlayer.replaceCurrentItem(with: playerItem);
        
        
    }
    
    @IBAction func xVideo(_ sender: UIButton) {
        avPlayer.pause();
        avPlayer = nil;
        let appDelegate =  AppDelegate.getAppDelegate();
        appDelegate.shouldRotate = false;
        self.viewWillLayoutSubviews();
        self.supportedInterfaceOrientations = UIInterfaceOrientationMask.portrait;
        self.videoView.removeFromSuperview();
        
        
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        avPlayerLayer.frame = view.frame;
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
            || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
            avPlayerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height );
        }
        
        
        
        
        
        
    }
    
    
    
    
    // Force the view into landscape mode (which is how most video media is consumed.)
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscape
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        avPlayerLayer.frame = videoView.bounds;
        //avPlayerLayer.transform = CATransform3DMakeRotation(CGFloat(90.0 / 180.0 * .pi), 0.0, 0.0, 1.0);
        avPlayer.play() // Start the playback
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get { return UIInterfaceOrientationMask.landscape }
        set { UIInterfaceOrientationMask.landscape }
    }
}
