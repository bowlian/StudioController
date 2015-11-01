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
    var prevControlsVC: MVControlsVC!
    var liveControlsVC: MVControlsVC!
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
        tableView.registerForDraggedTypes([NSStringPboardType, NSFilenamesPboardType])
    }
    
    override func viewDidAppear() {
        upSelRow()
        prevPlayerVC.chLive(false, Vcontrols: prevControlsVC)
        livePlayerVC.chLive(true, Vcontrols: liveControlsVC)
    }
    
    func upSelRow() {
        btnRemoveMedia.enabled = selectedRow != nil
        MPlayerVC.chMedia(selectedMedia, live: false)
    }

    @IBAction func btncAddMedia(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.runModal()
        for url in openPanel.URLs {
            Media.addMedia(Media(url: url), tableView: tableView)
        }
    }
    
    @IBAction func btncRemoveMedia(sender: NSButton) {
        if let selRow = selectedRow {
            Media.medias.removeAtIndex(selRow)
            tableView.removeRowsAtIndexes(NSIndexSet(index: selRow), withAnimation: .EffectFade)
        }
    }
    
    @IBAction func btncGoLive(sender: NSButton) {
        MPlayerVC.swapLive()
    }
    
    @IBAction func btncFetchWeather(sender: NSButton) {
        let nyialert = NSAlert()
        nyialert.messageText = "Not yet implemented! This feature will automatically download the most recent weather images and add them to the list."
        nyialert.runModal()
    }

    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationController as? MPlayerVC {
            if segue.identifier == "MPVCprev" {
                prevPlayerVC = dvc
            } else if segue.identifier == "MPVClive" {
                livePlayerVC = dvc
            }
        } else if let dvc = segue.destinationController as? MVControlsVC {
            if segue.identifier == "VCVCprev" {
                prevControlsVC = dvc
            } else if segue.identifier == "VCVClive" {
                liveControlsVC = dvc
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
        let durls = info.draggingPasteboard().readObjectsForClasses([NSURL.self], options: [NSPasteboardURLReadingFileURLsOnlyKey: true])
        if durls?.count > 0 { //Dragging file from Finder
            return .Copy
        } else { //Dragging existing row
            if dropOperation == .Above {
                return .Move
            } else {
                return .Every
            }
        }
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        var newMedias = [Media]()
        let durls = info.draggingPasteboard().readObjectsForClasses([NSURL.self], options: [NSPasteboardURLReadingFileURLsOnlyKey: true]) as? [NSURL]
        if durls?.count > 0 {
            for durl in durls! {
                let newMedi = Media(url: durl)
                newMedias.append(newMedi)
            }
        } else if let ddat = info.draggingPasteboard().dataForType(NSStringPboardType),
        rowIndexes = NSKeyedUnarchiver.unarchiveObjectWithData(ddat) as? NSIndexSet {
            newMedias.append(Media.medias[rowIndexes.firstIndex])
            Media.medias.removeAtIndex(rowIndexes.firstIndex)
            tableView.removeRowsAtIndexes(NSIndexSet(index: rowIndexes.firstIndex), withAnimation: .EffectFade)
        }
        for dmedi in newMedias {
            Media.addMedia(dmedi, index: row, tableView: tableView)
        }
        return newMedias.count > 0
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
        for (ilive, player) in players {
            player.muted = !ilive //Mute audio if not live
        }
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
    private var vcontrols: MVControlsVC?
    
    var isLive: Bool {
        return _isLive
    }
    
    func chLive(isLive: Bool, Vcontrols: MVControlsVC? = nil) {
        _isLive = isLive
        vcontrols = Vcontrols
        playerView.player = MPlayerVC.outPlayer(self)
        vcontrols?.setPlayer(playerView.player!)
        view.wantsLayer = true
        view.layer!.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor
    }
    
    private func changeMedia(newMedia: Media?) {
        if cmedia != newMedia {
            let isImg = newMedia?.isImg == true
            cmedia = newMedia
            imgView.image = newMedia?.image
            imgView.hidden = !isImg
            playerView.hidden = isImg
            let pvplayer = playerView.player as! VPlayer
            pvplayer.changeMedia(newMedia)
            vcontrols?.chMedia(newMedia)
        }
    }
}

class MVControlsVC: NSViewController {
    @IBOutlet weak var sliderPos: NSSlider!
    @IBOutlet weak var btnPlay: NSButton!
    @IBOutlet weak var lblPos: NSTextField!
    private var cmedia: Media?
    private var uptimer: NSTimer?
    private var player: AVPlayer?
    
    private var isPlaying: Bool {
        return player?.rate > 0
    }
    
    private func secStr(secs: Double) -> String {
        if secs.isNormal {
            let min = Int(secs / 60)
            let sec = Int(secs % 60)
            return String(min) + ":" + String(format: "%02d", sec)
        } else {
            return ""
        }
    }
    
    func chMedia(newMedia: Media?) {
        uptimer?.invalidate()
        cmedia = nil
        let mediaIsVideo = newMedia?.isImg == false
        if mediaIsVideo {
            cmedia = newMedia
            uptimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("up:"), userInfo: nil, repeats: true)
            uptimer?.fire()
        }
        self.view.hidden = !mediaIsVideo
    }
    func up(timer: NSTimer) {
        if isPlaying {
            btnPlay.title = "Pause"
        } else {
            btnPlay.title = "Play"
        }
        if let media = cmedia {
            let ctime = media.currentTime
            lblPos.stringValue = secStr(ctime) + " / " + secStr(media.length)
            sliderPos.hidden = media.length <= 0
            if !sliderPos.hidden {
                sliderPos.maxValue = media.length
                sliderPos.doubleValue = ctime
            }
        }
    }
    func setPlayer(newPlayer: AVPlayer) {
        player = newPlayer
        btnPlay.hidden = false
    }
    @IBAction func btncPlay(sender: NSButton) {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        uptimer?.fire()
    }
    @IBAction func sliderc(sender: NSSlider) {
        if let playe = player {
            playe.seekToTime(CMTime(seconds: sender.doubleValue, preferredTimescale: playe.currentTime().timescale))
        }
    }
}


