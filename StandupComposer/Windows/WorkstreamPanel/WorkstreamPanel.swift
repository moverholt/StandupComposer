//
//  WorkstreamPanel.swift
//  FEJournal
//
//  Created by Matt Overholt on 12/31/25.
//

import Cocoa

class WorkstreamPanel: NSPanel {
//    private var resignObserver: Any?
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    override func cancelOperation(_ sender: Any?) {
        self.close()
    }
    
//    override func becomeKey() {
//        super.becomeKey()
//        
//        resignObserver = NotificationCenter.default.addObserver(
//            forName: NSWindow.didResignKeyNotification,
//            object: self,
//            queue: .main
//        ) { [weak self] _ in
//            self?.close()
//        }
//    }
    
//    override func close() {
//        if let resignObserver {
//            NotificationCenter.default.removeObserver(resignObserver)
//        }
//        super.close()
//    }
}
