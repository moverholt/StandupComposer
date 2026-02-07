//
//  Standup.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import Foundation
import UniformTypeIdentifiers

enum SelectStandup: Codable, Hashable {
    case none
    case existing(Standup.ID)
    case new
    
    var id: Standup.ID? {
        switch self {
        case .existing(let id):
            return id
        case .none:
            return nil
        case .new:
            return nil
        }
    }
}

struct Standup: Codable, Identifiable {
    let id: UUID
    let workspaceId: Workspace.ID
    let rangeStart: Date
    var rangeEnd: Date?
    
    let previousStandupId: Standup.ID?
    var title: String
    let created: Date
    var updated: Date
    
    var previousStandId: Standup.ID?
    
    var entries: [WorkstreamEntry]
    
    var formattedSlack: String?
    
    private(set) var status: Status = .edit
    
    init(_ workspaceId: Workspace.ID) {
        self.init(
            "New Standup",
            workspaceId,
            start: Date.distantPast,
            previousStandId: nil
        )
    }

    init(
        _ title: String,
        _ workspaceId: Workspace.ID,
        start: Date,
        previousStandId: Standup.ID?
    ) {
        id = UUID()
        self.title = title
        let now = Date()
        created = now
        updated = now
        self.workspaceId = workspaceId
        entries = []
        rangeStart = start
        rangeEnd = nil
        self.previousStandupId = previousStandId
    }
    
    var editing: Bool { status == .edit }
    var published: Bool { status == .published }
    
    var day: IsoDay { rangeEnd?.isoDay ?? rangeStart.isoDay }

    var hasContentToFormat: Bool {
        entries.contains(where: { $0.minus24Draft != nil || $0.plus24Draft != nil })
    }
    
    mutating func publish() {
        rangeEnd = Date()
        status = .published
    }
    
    mutating func removeWorkstream(_ workstreamId: Workstream.ID) {
        entries.removeAll(where: { $0.workstreamId == workstreamId })
    }

    mutating func addWorkstream(_ stream: Workstream) -> WorkstreamEntry.ID {
        let entry = WorkstreamEntry(
            standId: self.id,
            streamId: stream.id
        )
        entries.append(entry)
        return entry.id
    }
}

extension Standup {
    enum Status: String, CustomStringConvertible, Codable, CaseIterable {
        case edit, published
        var description: String { self.rawValue }
    }
    
    mutating func touch() { updated = Date() }
}

extension [Standup] {
    func find(id: Standup.ID) -> Standup? {
        first(where: { $0.id == id })
    }
    
    func findIndex(id: Standup.ID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
    
    var editing: [Standup] {
        filter({ $0.status == .edit })
    }
    
    var published: [Standup] {
        filter({ $0.status == .published })
    }
}

extension [Standup.WorkstreamGenUpdate] {
    func find(
        wsid: Standup.WorkstreamGenUpdate.ID
    ) -> Standup.WorkstreamGenUpdate? {
        first(where: { $0.ws.id == wsid })
    }
    
    func findIndex(
        wsid: Standup.WorkstreamGenUpdate.ID
    ) -> Int? {
        firstIndex(where: { $0.ws.id == wsid })
    }
}

extension Standup {
    struct WorkstreamGenUpdate: Codable, Identifiable {
        struct WorkstreamMeta: Codable, Identifiable, Hashable {
            let id: UUID
            let title: String
            let issueKey: String?
            
            init(_ ws: Workstream) {
                id = ws.id
                title = ws.title
                issueKey = ws.issueKey
            }
        }
        
        struct GeneratorState: Codable, Hashable {
            var active: Bool = false
            var partial: String? = nil
            var final: String? = nil
            var error: String? = nil
        }
        
        let id: UUID
        let ws: WorkstreamMeta
        var body: String?
        var ai: GeneratorState
        
        init(_ ws: Workstream) {
            id = UUID()
            ai = GeneratorState()
            self.ws = WorkstreamMeta(ws)
        }
    }
}


extension Standup {
    struct WorkstreamEntry: Codable, Identifiable {
        let id: UUID
        let standupId: Standup.ID
        let workstreamId: Workstream.ID
        
        var minus24DraftNotes: String?
        var minus24Draft: String?
        var minus24Final: String?
        var minus24DraftGeneratedAt: Date?
        var minus24EditedAt: Date?
        
        var plus24DraftNotes: String?
        var plus24Draft: String?
        var plus24Final: String?
        var plus24DraftGeneratedAt: Date?
        var plus24EditedAt: Date?
        
        var reviewedAt: Date?
        var sortOrder: Int?
        
        init(
            standId: Standup.ID,
            streamId: Workstream.ID
        ) {
            id = UUID()
            self.standupId = standId
            self.workstreamId = streamId
        }
        
        var minus24: String? {
            minus24Final ?? minus24Draft
        }
        
        var plus24: String? {
            plus24Draft ?? plus24Final
        }
    }
}

