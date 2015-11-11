//
//  AppDelegate.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/21/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var outputWindow: NSWindowController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let owc = storyboard.instantiateControllerWithIdentifier("OutputWC") as? NSWindowController {
            outputWindow = owc
            owc.showWindow(self)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }

    @IBOutlet weak var menRemoveMedia: NSMenuItem!
    @IBOutlet weak var mControlLive: NSMenuItem!
    @IBOutlet weak var mControlPrev: NSMenuItem!
    @IBOutlet weak var mControlNext: NSMenuItem!
    @IBAction func menuRemoveMedia(sender: NSMenuItem) {
        StudioControllerVC.instance.btncRemoveMedia(NSButton())
    }
    @IBAction func menuControlLive(sender: NSMenuItem) {
        StudioControllerVC.instance.btncGoLive(NSButton())
    }
    @IBAction func menuControlPrev(sender: NSMenuItem) {
        StudioControllerVC.instance.btncPrev(NSButton())
    }
    @IBAction func menuControlNext(sender: NSMenuItem) {
        StudioControllerVC.instance.btncNext(NSButton())
    }
}
let AppDel = NSApplication.sharedApplication().delegate as! AppDelegate