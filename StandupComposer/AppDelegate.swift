//
//  AppDelegate.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/2/26.
//

import Cocoa
import Carbon
import SwiftUI

extension NSApplication {
    var appDelegate: AppDelegate? {
        self.delegate as? AppDelegate
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    private var settings = UserSettings.shared
    
    private var statusItem: NSStatusItem!
    private var hudUpdateController: HUDUpdatePanelController!
    private var dayChangeObserver: Any?
    private var hotKeyRef: EventHotKeyRef?
    private lazy var settingsController = SettingsWindowController(
        windowNibName: "SettingsWindowController"
    )
    private var wsPanelControllers: [Workstream.ID: WorkstreamPanelController] = [:]
    
    func applicationDidFinishLaunching(
        _ aNotification: Notification
    ) {
        setupStatusMenu()
        registerGlobalHotKey()
        installHotKeyHandler()
        
        dayChangeObserver = NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatusItemImage()
        }
        Task {
            populateStatusMenu()
        }
    }
    
    func applicationSupportsSecureRestorableState(
        _ app: NSApplication
    ) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let obs = dayChangeObserver {
            NotificationCenter.default.removeObserver(obs)
            dayChangeObserver = nil
        }
    }
    
    var currWSDoc: WorkspaceDocument? {
        let doc = NSDocumentController.shared.documents.first as? WorkspaceDocument
        return doc
    }
    
    @IBAction func handleOpenUpdateBar(_ sender: Any) {
        print("Handle open update bar!")
        toggleHUDUpdatePanel()
    }
    
    @IBAction func handleQuit(_ sender: Any) {
        NSApp.terminate(sender)
    }
    
    @IBAction func showSettings(_ sender: Any?) {
        settingsController.showWindow(self)
        settingsController.window?.makeKeyAndOrderFront(self)
    }
    
    
    @IBAction func handleNewStandup(_ sender: Any) {
        settings.workspaceSelected = .newStandup
        focus(currWSDoc)
    }
    
    private func focus(_ workspaceDocument: WorkspaceDocument?) {
        guard let doc = workspaceDocument else { return }
        
        if doc.windowControllers.isEmpty {
            doc.makeWindowControllers()
        }
        doc.showWindows()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func validateUserInterfaceItem(
        _ item: NSValidatedUserInterfaceItem
    ) -> Bool {
        return true
            //        switch item.action {
            //        case #selector(newDocument(_:)):
            //            return true
            //        default:
            //            return true
            //        }
    }
    
    private func setupStatusMenu() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        updateStatusItemImage()
        statusItem.menu = statusMenu
    }
    
    private func makeWorkstreamPanel(
        _ id: Workstream.ID
    ) -> WorkstreamPanelController? {
        print("Make controller for ID: \(id.uuidString)")
        guard let index = currWSDoc?.model.workspace.streams.findIndex(id: id) else {
            return nil
        }
        let cont = WorkstreamPanelController(
            windowNibName: "WorkstreamPanelController"
        )
        cont.stream = Binding(
            get: { self.currWSDoc!.model.workspace.streams[index] },
            set: { self.currWSDoc!.model.workspace.streams[index] = $0 }
        )
        wsPanelControllers[id] = cont
        return cont
    }
    
    private func getWorkstreamPanel(
        _ id: Workstream.ID
    ) -> WorkstreamPanelController? {
        if let cont = wsPanelControllers[id] {
            return cont
        } else {
            return makeWorkstreamPanel(id)
        }
    }
    
    private func updateStatusItemImage() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(
            systemSymbolName: "\(IsoDay.today.day).calendar",
            accessibilityDescription: "Journal"
        )
    }
    
    private func registerGlobalHotKey() {
        let hotKeyID = EventHotKeyID(
            signature: OSType(
                UInt32(
                    truncatingIfNeeded: "JWTM".utf8.reduce(0) { ($0 << 8) + UInt32($1) }
                )
            ),
            id: 1
        )
        
        let status = RegisterEventHotKey(
            UInt32(kVK_ANSI_U),              // U key
            UInt32(cmdKey | optionKey),      // ⌘ ⌥
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register hot key: \(status)")
        }
    }
    
    private func installHotKeyHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        // Pass a raw pointer to self into the Carbon callback
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                
                guard hotKeyID.id == 1 else { return noErr }
                
                DispatchQueue.main.async {
                    guard let userData else { return }
                    let appDelegate = Unmanaged<AppDelegate>
                        .fromOpaque(userData)
                        .takeUnretainedValue()
                    
                    print("Global hot key detected! Calling showHUDUpdate()")
                    appDelegate.toggleHUDUpdatePanel()
                }
                
                return noErr
            },
            1,
            &eventType,
            selfPtr,   // <-- this is the key change
            nil
        )
    }
    
    private let firstDividerTag = 1
    private let workstreamMenuItemTag = 2
    private let currentWSTag = 3
    
    func populateStatusMenu() {
        guard let firstDivide = statusMenu.item(
            withTag: firstDividerTag
        ) else {
            fatalError()
        }
        
        for item in statusMenu.items
        where item.tag == workstreamMenuItemTag || item.tag == currentWSTag {
            statusMenu.removeItem(item)
        }
        
        var i = statusMenu.index(of: firstDivide) + 1
        
        if let doc = currWSDoc {
            let item = NSMenuItem(
                title: "Workspace: \(doc.displayName ?? "")",
                action: #selector(handleClickWorkspace(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = currentWSTag
            statusMenu.insertItem(item, at: i)
            i += 1
        }
        
        let divider = NSMenuItem.separator()
        statusMenu.insertItem(divider, at: i)
        i += 1
        
        if let doc = currWSDoc {
            for ws in doc.model.workspace.streams.active {
                let item = NSMenuItem(
                    title: ws.description,
                    action: #selector(handleShowWorkstreamPanel(_:)),
                    keyEquivalent: ""
                )
                item.target = self
                item.tag = workstreamMenuItemTag
                item.representedObject = ws.id
                statusMenu.insertItem(item, at: i)
                i += 1
            }
        }
    }
    
    @objc private func handleClickWorkspace(_ sender: NSMenuItem?) {
        focus(currWSDoc)
    }
    
    @objc private func handleShowWorkstreamPanel(_ sender: NSMenuItem?) {
        guard let id = sender?.representedObject as? UUID else {
            return
        }
        print("Show workstream panel for: \(id.uuidString)")
        showWorkstreamPanel(id)
    }
    
    private func getHUDUpdateController() -> HUDUpdatePanelController? {
        guard let doc = currWSDoc else { return nil }
        let wspId = doc.model.workspace.id
        if hudUpdateController?.wspId == wspId {
            return hudUpdateController
        }
        let cont = HUDUpdatePanelController(
            windowNibName: "HUDUpdatePanelController"
        )
        cont.wspId = wspId
        cont.streams = Binding(
            get: { doc.model.workspace.streams },
            set: {
                doc.model.workspace.streams = $0
                doc.save(nil)
            }
        )
        hudUpdateController = cont
        return hudUpdateController
    }
    
    private func showHUDUpdatePanel() {
        if let cont = getHUDUpdateController() {
            cont.window?.makeKeyAndOrderFront(nil)
        }
    }
    
    private func hideHUDUpdatePanel() {
        hudUpdateController?.close()
    }
    
    private func toggleHUDUpdatePanel() {
        if hudUpdateController?.window?.isKeyWindow == true {
            hideHUDUpdatePanel()
        } else {
            showHUDUpdatePanel()
        }
    }
    
    func showWorkstreamPanel(_ id: Workstream.ID) {
        getWorkstreamPanel(id)?.panel.makeKeyAndOrderFront(nil)
    }
    
    private func hideWorkstreamPanel(_ id: Workstream.ID) {
        getWorkstreamPanel(id)?.close()
    }
    
    func showWorkstreamInWorkspace(_ id: Workstream.ID) {
        settings.workspaceSelected = .workstream(id)
        focus(currWSDoc)
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
}

