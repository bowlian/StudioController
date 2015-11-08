//
//  Data.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/28/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Foundation

class File: NSObject {
    //Reads & writes NSCoding-subclassed objects from NSUserDefaults
    private static var defaults = NSUserDefaults.standardUserDefaults()
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
    enum dk: String {
        case mediaList = "mediaList"
    }
    
    //Get path to application support folder & create if needed
    private static var _adURL: NSURL?
    static var adURL: NSURL {
        if let adurl = _adURL {
            return adurl
        }
        let adurl = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("StudioController/")
        if !NSFileManager.defaultManager().fileExistsAtPath(adurl.path!) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(adurl, withIntermediateDirectories: true, attributes: nil)
                print("Created directory in Application Support")
            } catch {
                print("Access denied to Application Support")
            }
        }
        _adURL = adurl
        return adurl
    }
    
    //Copy & delete files
    static func cp(fromURL: NSURL, toURL: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().copyItemAtURL(fromURL, toURL: toURL)
            return true
        } catch {
            print("Failed to copy \(fromURL) to \(toURL)")
            return false
        }
    }
    static func rm(deleteURL: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(deleteURL)
            return true
        } catch {
            print("Failed to delete \(deleteURL)")
            return false
        }
    }
    static func attrib(fileURL: NSURL, attributeKey: String) -> AnyObject? {
        do {
            if fileURL.fileURL {
                let attrs = try NSFileManager.defaultManager().attributesOfItemAtPath(fileURL.path!)
                return attrs[attributeKey]
            }
        } catch {}
        print("Failed to get attribute \(attributeKey) for \(fileURL)")
        return nil
    }
}

