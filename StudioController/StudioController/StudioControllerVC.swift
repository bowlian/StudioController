//
//  StudioControllerVC.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/21/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Cocoa

class StudioControllerVC: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func btncAddMedia(sender: NSButton) {
        let openPanel = NSOpenPanel(contentViewController: self)
        openPanel.beginWithCompletionHandler({(intres) in
            if intres == NSFileHandlingPanelOKButton {
                for selFile in openPanel.URLs {
                    print(selFile)
                }
            }
        })
    }
    @IBAction func btncRemoveMedia(sender: NSButton) {
    }
    @IBAction func btncLoadMedia(sender: NSButton) {
    }

}

