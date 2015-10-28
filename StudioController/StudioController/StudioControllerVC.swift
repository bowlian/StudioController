//
//  StudioControllerVC.swift
//  StudioController
//
//  Created by Bradley Klemick on 10/21/15.
//  Copyright © 2015 BradzTech. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class StudioControllerVC: NSViewController {
    
    var prevPlayerVC: MPlayerVC!
    var livePlayerVC: MPlayerVC!
    @IBOutlet weak var btnQueue: NSButton!
    @IBOutlet weak var btnFetchWeather: NSButton!
    @IBOutlet weak var btnRemoveMedia: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var selectedRow: Int? {
        let selRow = tableView.selectedRow
        if selRow >= 0 && selRow < Media.medias.count {
            return selRow
        } else {    //If no row is selected
            return nil
        }
    }
    var selectedMedia: Media? {
        if let selRow = selectedRow {
            return Media.medias[selRow]
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.registerForDraggedTypes([NSStringPboardType])
    }
    
    override func viewDidAppear() {
        upSelRow()
        prevPlayerVC.chLive(false)
        livePlayerVC.chLive(true)
    }
    
    func upSelRow() {
        btnRemoveMedia.enabled = selectedRow != nil
        btnQueue.enabled = selectedRow != nil
        MPlayerVC.chMedia(selectedMedia, live: false)
    }

    @IBAction func btncAddMedia(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.runModal()
        for url in openPanel.URLs {
            Media.medias.append(Media(url: url))
            tableView.insertRowsAtIndexes(NSIndexSet(index: Media.medias.count - 1), withAnimation: .SlideLeft)
        }
    }
    
    @IBAction func btncRemoveMedia(sender: NSButton) {
        if let selRow = selectedRow {
            Media.medias.removeAtIndex(selRow)
            tableView.removeRowsAtIndexes(NSIndexSet(index: selRow), withAnimation: .SlideLeft)
        }
    }
    
    @IBAction func btncGoLive(sender: NSButton) {
        MPlayerVC.swapLive()
    }

    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationController as? MPlayerVC {
            if segue.identifier == "MPVCprev" {
                prevPlayerVC = dvc
            } else if segue.identifier == "MPVClive" {
                livePlayerVC = dvc
            }
        }
    }
}

extension StudioControllerVC: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return Media.medias.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        let media = Media.medias[row]
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
                let dmedia = Media.medias[rowIndexes.firstIndex]
                Media.medias.removeAtIndex(rowIndexes.firstIndex)
                Media.medias.insert(dmedia, atIndex: row)
                tableView.reloadData()
                return true
        }
        return false
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        upSelRow()
    }
}

class MPlayerVC: NSViewController {
    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet private weak var playerView: AVPlayerView!
    
    //Static variables
    private static var insts = [MPlayerVC]()
    private static var players: [Bool: VPlayer] = [false: VPlayer(), true: VPlayer()]
    private static var medias: [Bool: Media?] = [false: nil, true: nil]
    private static var livePli: Bool = true
    
    private static func outPlayer(mpvc: MPlayerVC) -> VPlayer {
        if !insts.contains(mpvc) {
            insts.append(mpvc)
        }
        return players[mpvc.isLive]!
    }
    
    static func swapLive() {
        livePli = !livePli
        upPlayers()
    }
    
    private static func upPlayers() {
        for mpvc in insts {
            mpvc.changeMedia(medias[mpvc.isLive != livePli]!)
        }
    }
    
    static func chMedia(newMedia: Media?, live: Bool) {
        medias[live != livePli] = newMedia
        upPlayers()
    }
    
    //Instance variables
    private var _isLive: Bool = true
    private var cmedia: Media?
    
    var isLive: Bool {
        return _isLive
    }
    
    func chLive(isLive: Bool) {
        _isLive = isLive
        playerView.player = MPlayerVC.outPlayer(self)
    }
    
    private func changeMedia(newMedia: Media?) {
        if cmedia != newMedia {
            cmedia = newMedia
            imgView.image = newMedia?.image
            let isImg = imgView.image != nil
            imgView.hidden = !isImg
            playerView.hidden = isImg
            if !isImg {
                if let pvplayer = playerView.player as? VPlayer {
                    pvplayer.changeMedia(newMedia)
                }
            }
        }
    }
}


