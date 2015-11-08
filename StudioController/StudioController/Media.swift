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
    private var _url: NSURL
    var url: NSURL {
        return _url
    }
    let wid: Int
    var name: String
    var image: NSImage? {
        return NSImage(contentsOfURL: url) //Only works if valid image
    }
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
    private var _length: Double?
    var length: Double {
        if let lengt = _length {
            return lengt
        } else if !isImg {
            if let lpi = lastPlayerItem {
                if lpi.duration.seconds > 0 {
                    _length = lpi.duration.seconds
                    return _length!
                }
            }
        }
        return 0.0
    }
    var currentTime: Double {
        if let lpi = lastPlayerItem {
            return lpi.currentTime().seconds
        } else {
            return 0.0
        }
    }
    
    private var _time: CMTime?
    var time: CMTime? {
        return _time
    }
    
    private var localURL: NSURL {
        return File.adURL.URLByAppendingPathComponent("\(wid)").URLByAppendingPathExtension(url.pathExtension!)
    }
    private var isLocal: Bool {
        return url == localURL
    }
    func localCopy(var shouldChangeURL: Bool = false) -> Bool {
        if url.fileURL {
            if File.cp(url, toURL: localURL) {
                shouldChangeURL = true
            }
        }
        if shouldChangeURL {
            self._url = localURL
            Media.autoSaveMedias()
        }
        return shouldChangeURL
    }
    
    private var lastFetchedDate: NSDate? {
        if let modifiedDate = File.attrib(url, attributeKey: NSFileModificationDate) as? NSDate {
            return modifiedDate
        }
        return nil
    }
    var lastFetchedStr: String {
        if let lfd = lastFetchedDate,
        _ = self as? Weather {
            let dateForm = NSDateFormatter()
            if lfd.timeIntervalSinceNow < -3600 * 12 {
                dateForm.dateStyle = .ShortStyle
            }
            dateForm.timeStyle = .ShortStyle
            return dateForm.stringFromDate(lfd)
        }
        return ""
    }
    
    init(url: NSURL) {
        wid = Int(NSDate().timeIntervalSince1970)
        name = url.lastPathComponent!
        self._url = url
        super.init()
    }
    
    //Decode / Encode for file storage
    init(url: NSURL, wid: Int, name: String) {
        self._url = url
        self.wid = wid
        self.name = name
        super.init()
    }
    required convenience init?(coder: NSCoder) {
        if let url = coder.decodeObjectForKey("url") as? NSURL,
        wid = coder.decodeObjectForKey("wid") as? Int,
        name = coder.decodeObjectForKey("name") as? String {
            self.init(url: url, wid: wid, name: name)
        } else {
            return nil
        }
    }
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.url, forKey: "url")
        coder.encodeObject(self.wid, forKey: "wid")
        coder.encodeObject(self.name, forKey: "name")
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
            autoSaveMedias()
        }
    }
    static func autoSaveMedias() {
        File.dset(.mediaList, _medias)
    }
    static func addMedia(newMedia: Media, index: Int? = nil) {
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
        StudioControllerVC.TableView?.insertRowsAtIndexes(insertIndSet!, withAnimation: .EffectFade)
    }
    static func removeMedia(index: Int) {
        let delMedia = medias[index]
        if delMedia.isLocal {
            File.rm(delMedia.url)
        }
        medias.removeAtIndex(index)
        StudioControllerVC.TableView?.removeRowsAtIndexes(NSIndexSet(index: index), withAnimation: .EffectFade)
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

class Weather: Media {
    var remoteUrl: NSURL
    init(RemoteUrl: NSURL) {
        remoteUrl = RemoteUrl
        super.init(url: RemoteUrl)
        localCopy(true)
    }
    
    //Decode / Encode for file storage
    init(RemoteUrl: NSURL, url: NSURL, wid: Int, name: String) {
        remoteUrl = RemoteUrl
        super.init(url: url, wid: wid, name: name)
    }
    required convenience init?(coder: NSCoder) {
        if let remUrl = coder.decodeObjectForKey("remoteUrl") as? NSURL,
        url = coder.decodeObjectForKey("url") as? NSURL,
        wid = coder.decodeObjectForKey("wid") as? Int,
        name = coder.decodeObjectForKey("name") as? String {
            self.init(RemoteUrl: remUrl, url: url, wid: wid, name: name)
        } else {
            return nil
        }
    }
    override func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.remoteUrl, forKey: "remoteUrl")
        super.encodeWithCoder(coder)
    }
    
    func fetch(onLoad: ((Bool)->())? = nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { //Download in new thread
            var dlSuccess = false
            if let data = NSData(contentsOfURL: self.remoteUrl) {
                data.writeToURL(self.url, atomically: true)
                if self.isImg {
                    dlSuccess = true
                }
            }
            dispatch_async(dispatch_get_main_queue()) { //Execute in main thread for UI update
                onLoad?(dlSuccess)
            }
        }
    }
    
    static var weathers: [Weather] {
        var weathers = [Weather]()
        for media in Media.medias {
            if let weath = media as? Weather {
                weathers.append(weath)
            }
        }
        return weathers
    }
}

