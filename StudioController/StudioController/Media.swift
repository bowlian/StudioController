//
//  Media.swift
//  StudioController
//
//  Created by 🍕 Ian Bowler 🍕 on 10/22/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

class Media: NSObject {
    let url: NSURL
    var name: String {
        return url.lastPathComponent!
    }
    let image: NSImage?
    var playerItem: AVPlayerItem {
        return AVPlayerItem(URL: url)
    }
    
    init(url: NSURL){
        self.url = url
        image = NSImage(contentsOfURL: url) //Only works if valid image
        super.init()
    }
}

class VPlayer: AVPlayer {
    func changeMedia(newMedia: Media?) {
        if currentItem != newMedia?.playerItem {
            replaceCurrentItemWithPlayerItem(newMedia?.playerItem)
            play()
        }
    }
}

