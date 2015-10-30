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

class Media: NSObject, NSCoding {
    let url: NSURL
    var name: String {
        return url.lastPathComponent!
    }
    let image: NSImage?
    var isImg: Bool {
        return image != nil
    }
    private var _lastPlayerItem: AVPlayerItem?
    var lastPlayerItem: AVPlayerItem? {
        return _lastPlayerItem
    }
    func newPlayerItem() -> AVPlayerItem? {
        if !isImg {
            let newPI = AVPlayerItem(URL: url)
            _time = _lastPlayerItem?.currentTime()
            _lastPlayerItem = newPI
            return newPI
        }
        return nil
    }
    
    init(url: NSURL){
        self.url = url
        image = NSImage(contentsOfURL: url) //Only works if valid image
        super.init()
    }
    
    private var _time: CMTime?
    var time: CMTime? {
        return _time
    }
    
    //Decode / Encode for file storage
    required convenience init?(coder: NSCoder) {
        if let url = coder.decodeObjectForKey("url") as? NSURL {
            self.init(url: url)
        } else {
            return nil
        }
    }
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.url, forKey: "url")
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object {
            return obj.url == self.url
        }
        return false
    }
    
    //Array of all medias, with auto-save
    private static var _medias: [Media]?
    static var medias: [Media] {
        get {
            if _medias == nil {
                if let fileMedias = File.dget(.mediaList) as? [Media] {
                    _medias = fileMedias
                }
            }
            if let medias = _medias {
                return medias
            }
            return [Media]()
        } set {
            _medias = newValue
            File.dset(.mediaList, _medias)
        }
    }
    static func addMedia(newMedia: Media, index: Int? = nil, tableView: NSTableView? = nil) {
        if !medias.contains(newMedia) { //Prevent duplicates
            var insertIndSet: NSIndexSet?
            if let ind = index {
                if ind < medias.count {
                    insertIndSet = NSIndexSet(index: ind)
                    medias.insert(newMedia, atIndex: ind)
                }
            }
            if insertIndSet == nil {
                medias.append(newMedia)
                insertIndSet = NSIndexSet(index: medias.count - 1)
            }
            if let tableVie = tableView {
                tableVie.insertRowsAtIndexes(insertIndSet!, withAnimation: .EffectFade)
            }
        }
    }
}

class VPlayer: AVPlayer {
    func changeMedia(newMedia: Media?) {
        if currentItem != newMedia?.lastPlayerItem || newMedia?.lastPlayerItem == nil {
            replaceCurrentItemWithPlayerItem(newMedia?.newPlayerItem())
            if let seekTime = newMedia?.time {
                seekToTime(seekTime)
            }
            play()
        }
    }
}

