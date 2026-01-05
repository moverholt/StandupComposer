//
//  HUDUpdatePanelController.swift
//  FEJournal
//
//  Created by Matt Overholt on 12/29/25.
//

import Cocoa
import SwiftUI

class HUDUpdatePanelController: NSWindowController {
    var wspId: Workspace.ID!
    var streams: Binding<[Workstream]>!
    var panel: HUDUpdatePanel! { self.window as? HUDUpdatePanel }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        print("HUDUpdatePanelController - windowDidLoad")
        
        panel.level = .statusBar
        panel.backgroundColor = .clear

        let hostingController = NSHostingController(
            rootView: HUDUpdateContentView(models: streams)
        )
        self.contentViewController = hostingController
        panel.setFrameAutosaveName("hud-update-panel-4")
    }
}
