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
        dataArray.append(Media(name: "Hello", path: "TEST"))
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
                mediaController.addObject(Media(name: url.pathComponents!.last, path: url.path!))
                }
            }
        }
    
    @IBAction func btncRemoveMedia(sender: NSButton) {
        if let selectedMedia = mediaController.selectedObjects.first as? Media {
            mediaController.removeObject(selectedMedia)
        }
    }
     func btncLoadMedia(sender: NSButton) {
    }

}

