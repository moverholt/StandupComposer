//
//  WorkspaceDocument.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/2/26.
//

import Cocoa
import SwiftUI

    //@MainActor
@Observable
final class WorkspaceDocumentModel {
    var workspace: Workspace
    var workstreams: [Workstream]
    var standups: [Standup]
    
    init(workspace: Workspace, workstreams: [Workstream], standups: [Standup]) {
        self.workspace = workspace
        self.workstreams = workstreams
        self.standups = standups
    }
}

class WorkspaceDocument: NSDocument {
    var model: WorkspaceDocumentModel!
    
    override var windowNibName: String? {
        return "WorkspaceDocument"
    }
    
    override nonisolated class var autosavesInPlace: Bool {
        return true
    }
    
    override func showWindows() {
        super.showWindows()
        NSApp.appDelegate?.populateStatusMenu()
    }
    
    override func makeWindowControllers() {
        if model == nil {
            model = WorkspaceDocumentModel(
                workspace: Workspace(),
                workstreams: [],
                standups: []
            )
        }
        super.makeWindowControllers()
    }

    override func windowControllerDidLoadNib(_ cont: NSWindowController) {
        super.windowControllerDidLoadNib(cont)
        let hostingController = NSHostingController(
            rootView: WorkspaceContentView(
                streams: Binding(
                    get: { self.model.workstreams },
                    set: {
                        self.model.workstreams = $0
                        self.updateChangeCount(.changeDone)
                    }
                ),
                stands: Binding(
                    get: { self.model.standups },
                    set: {
                        self.model.standups = $0
                        self.updateChangeCount(.changeDone)
                    }
                ),
                selected: Binding(
                    get: { UserSettings.shared.workspaceSelected },
                    set: { UserSettings.shared.workspaceSelected = $0 }
                )
            )
        )
        cont.contentViewController = hostingController
    }
    
    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        var rootChildren: [String: FileWrapper] = [:]
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        // ---- Workspace.json (metadata + possibly embedded workstreams) ----
        let workspaceData = try encoder.encode(model.workspace)
        let workspaceWrapper = FileWrapper(regularFileWithContents: workspaceData)
        workspaceWrapper.preferredFilename = "Workspace.json"
        rootChildren["Workspace.json"] = workspaceWrapper
        
        // ---- Workstreams/ directory ----
        var workstreamChildren: [String: FileWrapper] = [:]
        
        for workstream in model.workstreams {
            let data = try encoder.encode(workstream)
            let filename = "\(workstream.id.uuidString).json"
            let fileWrapper = FileWrapper(regularFileWithContents: data)
            fileWrapper.preferredFilename = filename
            workstreamChildren[filename] = fileWrapper
        }
        
        let workstreamsFolder = FileWrapper(
            directoryWithFileWrappers: workstreamChildren
        )
        workstreamsFolder.preferredFilename = "Workstreams"
        rootChildren["Workstreams"] = workstreamsFolder
        
        // ---- Standups/ directory ----
        var standupChildren: [String: FileWrapper] = [:]
        
        for standup in model.standups {
            let data = try encoder.encode(standup)
            let filename = "\(standup.id.uuidString).json"
            let fileWrapper = FileWrapper(regularFileWithContents: data)
            fileWrapper.preferredFilename = filename
            standupChildren[filename] = fileWrapper
        }
        
        let standupsFolder = FileWrapper(
            directoryWithFileWrappers: standupChildren
        )
        standupsFolder.preferredFilename = "Standups"
        rootChildren["Standups"] = standupsFolder
        
        // ---- Root workspace package ----
        let rootWrapper = FileWrapper(directoryWithFileWrappers: rootChildren)
        return rootWrapper
    }
    
    override nonisolated func read(
        from fileWrapper: FileWrapper,
        ofType typeName: String
    ) throws {
        guard fileWrapper.isDirectory,
              let children = fileWrapper.fileWrappers else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
//        var loadedWorkspace = Workspace()  // default if no metadata
        var loadedWorkspace: Workspace? = nil
        
        // ---- Workspace.json (metadata: id, title, etc.) ----
        if let workspaceWrapper = children["Workspace.json"],
           let data = workspaceWrapper.regularFileContents {
            do {
                loadedWorkspace = try decoder.decode(Workspace.self, from: data)
            } catch {
                NSLog("Failed to decode Workspace.json: \(error)")
                    // fall back to default Workspace() if decode fails
            }
        }
        
        if loadedWorkspace == nil {
            Swift.print("NO LOADED WORKSPACE")
            fatalError()
        }
        
        // ---- Workstreams/ folder ----
        var loadedWorkstreams: [Workstream] = []
        
        if let workstreamsWrapper = children["Workstreams"],
           workstreamsWrapper.isDirectory,
           let workstreamFiles = workstreamsWrapper.fileWrappers {
            
            for (_, wrapper) in workstreamFiles {
                guard let data = wrapper.regularFileContents else { continue }
                do {
                    let workstream = try decoder.decode(
                        Workstream.self,
                        from: data
                    )
                    loadedWorkstreams.append(workstream)
                } catch {
                    NSLog("Failed to decode workstream: \(error)")
                }
            }
        }
        
        // ---- Standups/ folder ----
        var loadedStandups: [Standup] = []
        
        if let standupsWrapper = children["Standups"],
           standupsWrapper.isDirectory,
           let standupFiles = standupsWrapper.fileWrappers {
            
            for (_, wrapper) in standupFiles {
                guard let data = wrapper.regularFileContents else { continue }
                do {
                    let standup = try decoder.decode(
                        Standup.self,
                        from: data
                    )
                    loadedStandups.append(standup)
                } catch {
                    NSLog("Failed to decode standup: \(error)")
                }
            }
        }
        
//        Task { @MainActor in
            model = WorkspaceDocumentModel(
                workspace: loadedWorkspace!,
                workstreams: loadedWorkstreams,
                standups: loadedStandups
            )
//        }
    }
}

