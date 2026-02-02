//
//  StandDocWindowController.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/24/26.
//

import Cocoa
import SwiftUI

class StandDocWindowController: NSWindowController {
    var stand: Binding<Standup>!
    var space: Binding<Workspace>!

    override func windowDidLoad() {
        super.windowDidLoad()
        print("autosave:", window?.frameAutosaveName ?? "nil")
        print("loaded frame:", window?.frame as Any)
        
        DispatchQueue.main.async {
            print("frame next tick:", self.window?.frame as Any)
        }

        let hc = NSHostingController(
            rootView: StandDocContentView(space: space, stand: stand)
//                .frame(
//                    minWidth: 400,
//                    idealWidth: 600,
//                    minHeight: 400,
//                    idealHeight: 600
//                )
        )
//        if let w = window {
//            hc.preferredContentSize = w.contentLayoutRect.size
//        }

        print("preferred before:", hc.preferredContentSize)
        print("preferred minSize:", hc.preferredMinimumSize)
        contentViewController = hc
        window?.setFrameAutosaveName("StandDocWindowAutoSave")
    }
}
