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
        // Insert code here to tear down your application
    }


}

