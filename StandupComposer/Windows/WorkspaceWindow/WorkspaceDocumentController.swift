//
//  WorkspaceDocumentController.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/4/26.
//

import Cocoa


// NOTE: No longer using, but might come back to it
final class WorkspaceDocumentController: NSDocumentController {
    
    // MARK: - State
    
    private let lastWorkspaceKey = "WorkspaceDocumentController.lastWorkspaceURL"
    
    var currentWorkspace: WorkspaceDocument? {
        return documents.first as? WorkspaceDocument
    }
    
    // Close whatever workspace is currently open (we only ever want 0 or 1)
    private func closeCurrentWorkspaceIfNeeded() {
        for doc in documents {
            doc.close()
        }
    }
    
    // MARK: - New / Open
    
    /// Ensure at most one document exists when creating a new workspace.
    override func newDocument(_ sender: Any?) {
        closeCurrentWorkspaceIfNeeded()
        super.newDocument(sender)
    }
    
    /// Async open: called by File ▸ Open, recent items, Finder double-click, etc.
    override func openDocument(
        withContentsOf url: URL,
        display displayDocument: Bool
    ) async throws -> (NSDocument, Bool) {
        
        // Make sure we don’t end up with two workspaces at once.
        closeCurrentWorkspaceIfNeeded()
        
        let (doc, wasAlreadyOpen) = try await super.openDocument(
            withContentsOf: url,
            display: displayDocument
        )
        
        if let fileURL = doc.fileURL {
            rememberLastWorkspaceURL(fileURL)
        }
        
        return (doc, wasAlreadyOpen)
    }
    
    // MARK: - Document removal
    
    /// Called when a document is closed and removed from the controller's list
    override func removeDocument(_ document: NSDocument) {
        super.removeDocument(document)
        
            // Previous behavior:
            // - If `documents` was empty, we reopened the last workspace or created a new one.
            //
            // New behavior:
            // - Do nothing special. It's now valid for there to be 0 workspace windows.
            // - `documents` may be empty, which is allowed.
    }
    
    // MARK: - Last workspace persistence
    
    func rememberLastWorkspaceURL(_ url: URL) {
        UserDefaults.standard.set(url.path, forKey: lastWorkspaceKey)
    }
    
    /// Tries to reopen the last-used workspace file.
    /// Returns true on success, false if no valid file was found or open failed.
    /// (You can call this from AppDelegate on launch if you still want “reopen last on launch.”)
    func openLastWorkspaceIfPossible() async -> Bool {
        let defaults = UserDefaults.standard
        guard let path = defaults.string(forKey: lastWorkspaceKey) else {
            return false
        }
        
        guard FileManager.default.fileExists(atPath: path) else {
            return false
        }
        
        do {
            let url = URL(fileURLWithPath: path)
            
            let (doc, _) = try await openDocument(
                withContentsOf: url,
                display: true
            )
            
            if let fileURL = doc.fileURL {
                rememberLastWorkspaceURL(fileURL)
            }
            
            return true
        } catch {
            print("Failed to reopen last workspace: \(error)")
            return false
        }
    }
}
