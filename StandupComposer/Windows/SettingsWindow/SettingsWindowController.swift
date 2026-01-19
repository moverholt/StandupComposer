//
//  SettingsWindowController.swift
//  FEJournal
//
//  Created by Matt Overholt on 12/30/25.
//

import Cocoa
import SwiftUI

class SettingsWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        let hostingController = NSHostingController(
            rootView: SettingsWindowContentView()
                .scenePadding()
                .environment(UserSettings.shared)
        )
        self.contentViewController = hostingController
    }
}
