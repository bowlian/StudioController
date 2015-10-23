//
//  OutputVC.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/21/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

class OutputVC: NSViewController {
    var vid: MPlayerVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vid.chLive(true)
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationController as? MPlayerVC {
            if segue.identifier == "MPVCout" {
                vid = dvc
            }
        }
    }
}
