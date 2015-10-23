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

class Media : NSObject {
    let url: NSURL
    var playerItem: AVPlayerItem? {
        if filetype == .video || filetype == .audio {
            return AVPlayerItem(URL: url)
        } else {
            return nil
        }
    }
    var name: String {
        return url.lastPathComponent!
    }
    var filetype: Filetype {
        let p = url.pathExtension?.lowercaseString
        if p == "mpg" || p == "mpeg" || p == "mov" || p == "mp4" || p == "flv" {
            return .video
        } else if p == "jpg" || p == "jpeg" || p == "tif" || p == "tiff" || p == "png" || p == "gif" {
            return .photo
        } else if p == "ogg" || p == "m4a" || p == "wav" || p == "mp3" {
            return .audio
        } else {
            return .nonMedia
        }
    }
    
    init(url: NSURL){
        self.url = url
        super.init()
    }
    
    enum Filetype {
        case photo
        case video
        case audio
        case nonMedia
    }
    
    var image: NSImage? {
        if filetype == .photo {
            return NSImage(contentsOfURL: url)
        } else {
            return nil
        }
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

class VPlayerView: AVPlayerView {
    var isLive: Bool!
    func chLive(isLivePlayer: Bool) {
        isLive = isLivePlayer
        upPlayer()
    }
    func upPlayer() {
        self.player = MPlayerVC.out(isLive, playerView: self)
    }
}
