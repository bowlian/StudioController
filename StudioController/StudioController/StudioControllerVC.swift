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
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnPrev: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var indFetching: NSProgressIndicator!
    @IBOutlet weak var lblFetching: NSTextField!
    static var instance: StudioControllerVC!
    
    var selectedRow: Int? {
        let selRows = tableView.selectedRowIndexes
        let selRow = selRows.lastIndex
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
        StudioControllerVC.instance = self
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.registerForDraggedTypes([NSStringPboardType, NSFilenamesPboardType])
        tableView.sizeToFit()
    }
    
    override func viewDidAppear() {
        upSelRow()
        prevPlayerVC.chLive(false, Vcontrols: prevControlsVC)
        livePlayerVC.chLive(true, Vcontrols: liveControlsVC)
        if view.window!.styleMask & NSClosableWindowMask != 0 {    //Guarantees that the close button is hidden
            view.window!.styleMask -= NSClosableWindowMask
        }
    }
    
    func upSelRow() {
        //Intelligently show/hide buttons based on selected items
        let isRowSel = selectedRow != nil
        let canPrev = selectedRow > 0
        let canNext = isRowSel && selectedRow < numberOfRowsInTableView(tableView) - 1
        btnRemoveMedia.enabled = isRowSel
        btnPrev.enabled = canPrev
        btnNext.enabled = canNext
        AppDel.menRemoveMedia.enabled = isRowSel
        AppDel.mControlPrev.enabled = canPrev
        AppDel.mControlNext.enabled = canNext
        
        if liveNexting {    //If next/prev button, disable preview
            MPlayerVC.chMedia(nil, live: false)
        } else {    //If normal selection change, update preview
            MPlayerVC.chMedia(selectedMedia, live: false)
        }
    }
    
    @IBAction func btncAddMedia(sender: NSButton) {
        performSegueWithIdentifier("AddMedia", sender: self)
    }
    @IBAction func btncRemoveMedia(sender: NSButton) {
        let selInds = tableView.selectedRowIndexes
        var selInd = selInds.firstIndex
        var numRemoved = 0
        while selInd != NSNotFound {    //Apple's recommended method for index iteration
            Media.removeMedia(selInd - numRemoved++)
            selInd = selInds.indexGreaterThanIndex(selInd)
        }
    }
    
    @IBAction func btncGoLive(sender: NSButton) {
        MPlayerVC.swapLive()
    }
    @IBAction func btncPrev(sender: NSButton) {
        liveNext(-1)
    }
    @IBAction func btncNext(sender: NSButton) {
        liveNext(1)
    }
    private var liveNexting = false    //Allows upSelRow to determine if next/prev button was used
    private func liveNext(increment: Int) {
        liveNexting = true
        if let selRow = selectedRow {
            let newRow = selRow + increment
            let newMedia = Media.medias[newRow]
            MPlayerVC.chMedia(newMedia, live: true)
            tableView.selectRowIndexes(NSIndexSet(index: newRow), byExtendingSelection: false)
        }
        liveNexting = false
    }
    
    @IBAction func btncFetchWeather(sender: NSButton) {
        FetchProg().fetch(self)
    }
    class FetchProg {
        static var currentFetch: FetchProg?
        var weathers: [Weather] = Weather.weathers
        var count: Int {
            return weathers.count
        }
        var success: Int = 0
        var failed: Int = 0
        var total: Int {
            return success + failed
        }
        var canceled = false
        var vc: StudioControllerVC!
        func fetch(VC: StudioControllerVC) {
            vc = VC
            FetchProg.currentFetch?.cancel()
            FetchProg.currentFetch = self
            vc.upFetchInd(true)
            for weather in weathers {
                if !canceled {
                    weather.fetch({(dlSuccess) in
                        if dlSuccess {
                            self.success++
                        } else {
                            self.failed++
                        }
                        self.vc.upFetchInd()
                    })
                }
            }
        }
        func cancel() {
            canceled = true
        }
    }
    
    var fetchAgoTimer: NSTimer?
    func upFetchInd(startAnimation: Bool = false) {
        if startAnimation {
            indFetching.startAnimation(self)
            btnFetchWeather.enabled = false
        }
        if let fp = FetchProg.currentFetch {
            if fp.total < fp.count {
                lblFetching.stringValue = "\(fp.success)/\(fp.count)"
                lblFetching.textColor = NSColor(red: 0.2, green: 0, blue: 0.9, alpha: 1)
            } else {
                indFetching.stopAnimation(self)
                btnFetchWeather.enabled = true
                if fp.failed > 0 {
                    var fpfs = ""
                    if fp.failed > 1 {
                        fpfs = "s"
                    }
                    lblFetching.stringValue = "Done. \(fp.failed) error\(fpfs)."
                    lblFetching.textColor = NSColor(red: 0.9, green: 0, blue: 0.2, alpha: 1)
                } else {
                    lblFetching.stringValue = "Success!"
                    lblFetching.textColor = NSColor(red: 0, green: 0.7, blue: 0.2, alpha: 1)
                }
            }
            tableView.reloadData()
        }
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

extension StudioControllerVC: NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return Media.medias.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        let media = Media.medias[row]
        switch tableColumn!.identifier {
        case "NameCol":
            cellView.textField!.stringValue = media.name
        case "LastDateCol":
            cellView.textField!.stringValue = media.lastFetchedStr
        default:
            break
        }
        if let _ = media as? Weather {
            cellView.textField!.textColor = NSColor(red: 0.2, green: 0, blue: 0.8, alpha: 1)
        } else {
            cellView.textField!.textColor = NSColor.blackColor()
        }
        cellView.textField!.delegate = self
        return cellView
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let media = Media.medias[tableView.selectedRow]
        media.name = control.stringValue
        Media.autoSaveMedias()
        return true
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
            Media.addMedia(dmedi, index: row)
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

class SCAddMediaVC: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var btnAddFile: NSButton!
    @IBOutlet weak var btnAddURL: NSButton!
    @IBOutlet weak var btnAddURLDone: NSButton!
    @IBOutlet weak var txtURL: NSTextField!
    @IBOutlet weak var lblTipDrag: NSTextField!
    @IBOutlet weak var indDownloading: NSProgressIndicator!
    
    var enteredURL: NSURL? {
        if let url = NSURL(string: txtURL.stringValue) {
            if url.host != nil {
                return url
            }
        }
        return nil
    }
    
    @IBAction func btncAddFile(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.runModal()
        for url in openPanel.URLs {
            Media.addMedia(Media(url: url))
        }
        dismissViewController(self)
    }
    @IBAction func btncAddURL(sender: NSButton) {
        txtURL.hidden = false
        btnAddURLDone.hidden = false
        btnAddURL.hidden = true
        lblTipDrag.hidden = true
        btnAddFile.enabled = false
    }
    @IBAction func btncCancel(sender: NSButton) {
        dismissViewController(self)
    }
    override func controlTextDidChange(obj: NSNotification) {
        btnAddURLDone.enabled = txtURL.stringValue.characters.count > 3
    }
    @IBAction func btncAddURLDone(sender: NSButton) {
        if let url = enteredURL { //If entered text is a valid URL
            btnAddURLDone.enabled = false
            let weath = Weather(RemoteUrl: url)
            indDownloading.startAnimation(self)
            weath.fetch({(dlSuccess) in
                self.indDownloading.stopAnimation(self)
                if dlSuccess {
                    Media.addMedia(weath)
                    self.dismissViewController(self)
                } else {
                    self.urlFailAlert(true)
                }
            })
        } else {
            urlFailAlert(false)
        }
    }
    func urlFailAlert(isUrlValid: Bool) {
        let ufalert = NSAlert()
        if isUrlValid {
            ufalert.messageText = "An image was not found at this link."
        } else {
            ufalert.messageText = "Invalid URL"
        }
        ufalert.informativeText = "Please ensure the URL you entered is valid."
        ufalert.runModal()
        btnAddURLDone.enabled = true
    }
}


