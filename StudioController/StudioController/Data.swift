//
//  Data.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/28/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Foundation

class File: NSObject {
    static var x = File()
    private static var defaults = NSUserDefaults.standardUserDefaults()
    enum dk: String {
        case mediaList = "mediaList"
        case weathers = "weathers"
    }
    static func dget(dk: File.dk) -> NSCoding? {
        if let dat = defaults.objectForKey(dk.rawValue) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(dat) as? NSCoding
        }
        return nil
    }
    static func dset(dk: File.dk, _ obj: NSCoding?) {
        var dat: NSData?
        if let ob = obj {
            dat = NSKeyedArchiver.archivedDataWithRootObject(ob)
        }
        defaults.setObject(dat, forKey: dk.rawValue)
    }
    static var adURL: NSURL {
        let adurl = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("StudioController/")
        if !NSFileManager.defaultManager().fileExistsAtPath(adurl.path!) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(adurl, withIntermediateDirectories: true, attributes: nil)
                print(adurl)
            } catch {
                print("Access denied to Application Support")
            }
        }
        return adurl
    }
    
    static func copyFile(fromUrl: NSURL, toURL: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().copyItemAtURL(fromUrl, toURL: toURL)
            
            return true
        } catch {
            print("Failed to copy \(fromUrl) to \(toURL)")
            return false
        }
    }
}

