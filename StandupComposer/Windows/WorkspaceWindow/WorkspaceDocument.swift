//
//  WorkspaceDocument.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/2/26.
//

import Cocoa
import SwiftUI

@Observable
final class WorkspaceDocumentModel {
    var workspace: Workspace

    init(workspace: Workspace) {
        self.workspace = workspace
    }
}

class WorkspaceDocument: NSDocument {
    var model: WorkspaceDocumentModel!
    private var pendingAutosaveWorkItem: DispatchWorkItem?
    private static let autosaveDebounceInterval: TimeInterval = 1.5

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
            model = WorkspaceDocumentModel(workspace: Workspace())
        }
        super.makeWindowControllers()
    }

    override func windowControllerDidLoadNib(_ cont: NSWindowController) {
        super.windowControllerDidLoadNib(cont)
        let hostingController = NSHostingController(
            rootView: WorkspaceContentView(
                workspace: Binding(
                    get: { self.model.workspace },
                    set: {
                        self.model.workspace = $0
                        self.updateChangeCount(.changeDone)
                    }
                )
            )
            .environment(UserSettings.shared)
        )

        cont.contentViewController = hostingController

        if let window = cont.window {
            window.setContentSize(NSSize(width: 1000, height: 620))
        }
    }

    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        var rootChildren: [String: FileWrapper] = [:]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // ---- Workspace.json (metadata + possibly embedded workstreams) ----
        let workspaceData = try encoder.encode(model.workspace.meta)
        let workspaceWrapper = FileWrapper(regularFileWithContents: workspaceData)
        workspaceWrapper.preferredFilename = "Workspace.json"
        rootChildren["Workspace.json"] = workspaceWrapper

        // ---- Workstreams/ directory ----
        var workstreamChildren: [String: FileWrapper] = [:]

        for workstream in model.workspace.streams {
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

        for standup in model.workspace.stands {
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
        try MainActor.assumeIsolated {
            guard fileWrapper.isDirectory,
                let children = fileWrapper.fileWrappers
            else {
                throw CocoaError(.fileReadCorruptFile)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            var loadedWorkspaceMeta: Workspace.Meta? = nil

            // ---- Workspace.json (metadata: id, title, etc.) ----
            if let workspaceWrapper = children["Workspace.json"],
                let data = workspaceWrapper.regularFileContents
            {
                do {
                    loadedWorkspaceMeta =
                        try decoder
                        .decode(Workspace.Meta.self, from: data)
                } catch {
                    NSLog("Failed to decode Workspace.json: \(error)")
                    // fall back to default Workspace() if decode fails
                }
            }

            if loadedWorkspaceMeta == nil {
                Swift.print("No loaded workspace meta file!")
                fatalError()
            }

            // ---- Workstreams/ folder ----
            var loadedWorkstreams: [Workstream] = []

            if let workstreamsWrapper = children["Workstreams"],
                workstreamsWrapper.isDirectory,
                let workstreamFiles = workstreamsWrapper.fileWrappers
            {

                for (_, wrapper) in workstreamFiles {
                    guard let data = wrapper.regularFileContents else { continue }
                    do {
                        let ws = try decoder.decode(Workstream.self, from: data)
                        loadedWorkstreams.append(ws)
                    } catch {
                        NSLog("Failed to decode workstream: \(error)")
                    }
                }
            }

            // ---- Standups/ folder ----
            var loadedStandups: [Standup] = []

            if let standupsWrapper = children["Standups"],
                standupsWrapper.isDirectory,
                let standupFiles = standupsWrapper.fileWrappers
            {

                for (_, wrapper) in standupFiles {
                    guard let data = wrapper.regularFileContents else { continue }
                    do {
                        let st = try decoder.decode(Standup.self, from: data)
                        loadedStandups.append(st)
                    } catch {
                        NSLog("Failed to decode standup: \(error)")
                    }
                }
            }

            let workspace = Workspace(
                meta: loadedWorkspaceMeta!,
                streams: loadedWorkstreams,
                stands: loadedStandups
            )

            model = WorkspaceDocumentModel(workspace: workspace)
        }
    }
}
