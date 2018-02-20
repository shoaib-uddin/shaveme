//
//  AVPlayerVC.swift
//  Shave Me
//
//  Created by Xtreme Hardware on 15/02/2018.
//  Copyright © 2018 NoorAli. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

class AVPlayerVC: UIViewController {

    var avPlayer: AVPlayer!;
    var avPlayerLayer: AVPlayerLayer!;
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        
        let appDelegate =  AppDelegate.getAppDelegate();
        appDelegate.shouldRotate = true;
        
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        avPlayer = AVPlayer();
        avPlayerLayer = AVPlayerLayer(player: avPlayer);
        
        
        self.view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        let path = Bundle.main.path(forResource: "video", ofType: "mp4");
        //let url = NSURL(string: path!);
        let playerItem = AVPlayerItem.init(url: URL(fileURLWithPath: path!));
        avPlayer.replaceCurrentItem(with: playerItem);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        avPlayerLayer.frame = view.bounds;
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        avPlayer.play() // Start the playback
    }
    
    @IBAction func xVideo(_ sender: UIButton) {
        avPlayer.pause();
        avPlayer = nil;
        let appDelegate =  AppDelegate.getAppDelegate();
        appDelegate.shouldRotate = false;
        self.viewWillLayoutSubviews();
        //self.supportedInterfaceOrientations = UIInterfaceOrientationMask.portrait;
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.dismiss(animated: false, completion: {
                // nil
            })
        }
        
        
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        get { return UIInterfaceOrientationMask.landscape | UIInterfaceOrientationMask.portrait  }
//        set { UIInterfaceOrientationMask.landscape | UIInterfaceOrientationMask.portrait }
//    }
    
}
