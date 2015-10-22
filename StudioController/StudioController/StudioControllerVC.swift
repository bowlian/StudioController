//
//  StudioControllerVC.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/21/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Cocoa

extension Array {
    var last: Element {
        return self[self.endIndex - 1]
    }
}

class StudioControllerVC: NSViewController {
    
    @IBOutlet var mediaController: NSArrayController!
    
    dynamic var dataArray = [Media]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func btncAddMedia(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.runModal()
        if !openPanel.URLs.isEmpty{
            for url in openPanel.URLs{
                mediaController.addObject(Media(url: url))
            }
        }
    }
    
    @IBAction func btncRemoveMedia(sender: NSButton) {
        for remMedia in mediaController.selectedObjects {
            mediaController.removeObject(remMedia)
        }
    }
     func btncLoadMedia(sender: NSButton) {
    }

}

