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
    
    @IBOutlet weak var btnQueue: NSButton!
    @IBOutlet weak var btnFetchWeather: NSButton!
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
        tableView.registerForDraggedTypes([NSStringPboardType])
        upSelRow()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return medias.count
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
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        let ddat = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
        let registeredTypes = [NSStringPboardType]
        pboard.declareTypes(registeredTypes, owner: self)
        pboard.setData(ddat, forType: NSStringPboardType)
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if dropOperation == .Above {
            return .Move
        } else {
            return .Every
        }
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if let ddat = info.draggingPasteboard().dataForType(NSStringPboardType),
        rowIndexes = NSKeyedUnarchiver.unarchiveObjectWithData(ddat) as? NSIndexSet {
            let dmedia = medias[rowIndexes.firstIndex]
            medias.removeAtIndex(rowIndexes.firstIndex)
            medias.insert(dmedia, atIndex: row)
            tableView.reloadData()
            return true
        }
        return false
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        print("Selected row = \(selectedRow)")
        upSelRow()
    }
    func upSelRow() {
        btnRemoveMedia.enabled = selectedRow != nil
        
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

