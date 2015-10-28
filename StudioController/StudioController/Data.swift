//
//  Data.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/28/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Foundation

class File {
    static var x = File()
    private static var defaults = NSUserDefaults.standardUserDefaults()
    enum dk: String {
        case mediaList = "mediaList"
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
}

extension File {
    
}