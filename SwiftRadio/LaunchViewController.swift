//
//  NavigationViewController.swift
//  SwiftRadio
//
//  Created by lucas.garcia on 2/8/21.
//  Copyright © 2021 matthewfecher.com. All rights reserved.
//

import AVKit
import AVFoundation
import UIKit

class LaunchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let item = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "launchGif", ofType: "mp4")!))
        let player = AVPlayer(playerItem: item)
        let layer = AVPlayerLayer(player: player)
        
        layer.frame = view.bounds
        layer.videoGravity = .resize
        view.layer.addSublayer(layer)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)

        player.play()
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        performSegue(withIdentifier: "NavigationController", sender: self)
    }
}
