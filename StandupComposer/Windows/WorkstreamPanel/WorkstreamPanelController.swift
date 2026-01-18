//
//  WorkstreamPanelController.swift
//  FEJournal
//
//  Created by Matt Overholt on 12/31/25.
//

import Cocoa
import SwiftUI

class WorkstreamPanelController: NSWindowController {
    var stream: Binding<Workstream>!

    var panel: WorkstreamPanel! { self.window as? WorkstreamPanel }

    override func windowDidLoad() {
        super.windowDidLoad()

        panel.level = .statusBar
        panel.backgroundColor = .clear
        
        let hostingController = NSHostingController(
            rootView: WorkstreamPanelContentView(stream: stream)
        )
        self.contentViewController = hostingController
    }
    
}
