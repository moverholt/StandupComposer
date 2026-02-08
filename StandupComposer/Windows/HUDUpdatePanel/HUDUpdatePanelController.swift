//
//  HUDUpdatePanelController.swift
//  FEJournal
//
//  Created by Matt Overholt on 12/29/25.
//

import Cocoa
import SwiftUI

class HUDUpdatePanelController: NSWindowController {
    var space: Binding<Workspace>!
    var panel: HUDUpdatePanel! { self.window as? HUDUpdatePanel }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        print("HUDUpdatePanelController - windowDidLoad")
        
        panel.level = .statusBar
        panel.backgroundColor = .clear

        let hostingController = NSHostingController(
            rootView: HUDUpdateContentView(space: space)
        )
        self.contentViewController = hostingController
         panel.setFrameAutosaveName("hud-update-panel-4")
    }
}
