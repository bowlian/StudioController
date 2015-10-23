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

extension Array {
    var last: Element {
        return self[self.endIndex - 1]
    }
}

class StudioControllerVC: NSViewController {
    
    var prevPlayerVC: MPlayerVC!
    var livePlayerVC: MPlayerVC!
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
    var selectedMedia: Media? {
        if let selRow = selectedRow {
            return medias[selRow]
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
        prevPlayerVC.changeMedia(selectedMedia)
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
}

class MPlayerVC: NSViewController {
    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet private weak var playerViewA: VPlayerView!
    @IBOutlet weak var playerViewB: VPlayerView!
    
    private static var players: [Bool: MPlayerVC!] = [false: nil, true: nil]
    private static var livePli: Bool = true
    static var outputs = [VPlayerView]()
    
    static func out(live: Bool, playerView: VPlayerView) -> VPlayer? {
        if !MPlayerVC.outputs.contains(playerView) {
            MPlayerVC.outputs.append(playerView)
        }
        if let gotPlayer = MPlayerVC.players[live != livePli] {
            return gotPlayer.shownPlayer?.player as? VPlayer
        }
        return nil
    }
    static func swapLive() {
        livePli = !livePli
        for output in outputs {
            output.upPlayer()
        }
    }
    
    private var isPlayerA = true
    private var cmedia: Media?
    private var viewIsLoaded: Bool {
        return playerViewA != nil && playerViewB != nil
    }
    private var shownPlayer: VPlayerView? {
        if !viewIsLoaded {
            return nil
        }
        if isPlayerA {
            return playerViewA
        } else {
            return playerViewB
        }
    }
    private var hiddenPlayer: VPlayerView {
        if isPlayerA {
            return playerViewB
        } else {
            return playerViewA
        }
    }
    var player: VPlayer? {
        return shownPlayer?.player as? VPlayer
    }
    
    private func swapPlayers() {
        isPlayerA = !isPlayerA
    }
    private func upPlayers() {
        let isPhoto = cmedia?.filetype == Media.Filetype.photo
        playerViewA.hidden = !isPlayerA || isPhoto
        playerViewB.hidden = isPlayerA || isPhoto
        imgView.hidden = !isPhoto
    }
    
    func changeMedia(newMedia: Media?) {
        cmedia = newMedia
        if let img = newMedia?.image {
            imgView.image = img
        } else if let playerItem = newMedia?.playerItem {
            if let vplaye = shownPlayer?.player as? VPlayer {
                vplaye.changeMedia(newMedia)
            }
        }
        upPlayers()
    }
    
    func chLive(live: Bool) {
        hiddenPlayer.chLive(live)
        swapPlayers()
        upPlayers()
    }
}


