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

class StudioControllerVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var btnRemoveMedia: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    var medias = [Media]()
    
    var selectedRow: Int? {
        let selRow = tableView.selectedRow
        if selRow >= 0 && selRow < medias.count {
            return selRow
        } else {    //If no row is selected
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
        tableView.setDataSource(self)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return medias.count
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return nil
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        let media = medias[row]
        switch tableColumn!.identifier {
        case "NameCol":
            cellView.textField!.stringValue = media.name
        default:
            break
        }
        return cellView
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        print("Selected row = \(selectedRow)")
        btnRemoveMedia.enabled = selectedRow != nil
        //Refresh previews
    }

    @IBAction func btncAddMedia(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.runModal()
        for url in openPanel.URLs {
            medias.append(Media(url: url))
            tableView.insertRowsAtIndexes(NSIndexSet(index: medias.count - 1), withAnimation: .SlideLeft)
        }
    }
    
    @IBAction func btncRemoveMedia(sender: NSButton) {
        if let selRow = selectedRow {
            medias.removeAtIndex(selRow)
            tableView.removeRowsAtIndexes(NSIndexSet(index: selRow), withAnimation: .SlideLeft)
        }
    }
    
    func btncLoadMedia(sender: NSButton) {
        
    }

}

