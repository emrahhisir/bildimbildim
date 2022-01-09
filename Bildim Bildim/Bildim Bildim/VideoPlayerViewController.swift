//
//  VideoPlayerViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 5/23/15.
//  Copyright (c) 2015 Emrah Hisir. All rights reserved.
//

import Foundation
import MediaPlayer

class VideoPlayerViewController: GenericDetailViewController {
    var moviePlayer : MPMoviePlayerController?
    var videoPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideo()
    }
    
    func playVideo() {
        let url = NSURL.fileURLWithPath(videoPath!)
        moviePlayer = MPMoviePlayerController(contentURL: url)
        if let player = moviePlayer {
            player.view.frame = self.view.bounds
            player.prepareToPlay()
            player.scalingMode = .AspectFill
            self.view.addSubview(player.view)
        }
    }
}