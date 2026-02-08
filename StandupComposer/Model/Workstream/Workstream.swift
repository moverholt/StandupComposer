//
//  Workstream.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/14/25.
//

import Foundation
import Observation
import UniformTypeIdentifiers

extension [Workstream] {
    func find(id: UUID) -> Workstream? {
        first(where: { $0.id == id })
    }
    
    func findIndex(id: UUID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
    
    var active: [Workstream] {
        filter({ $0.status == .active })
    }
    
    var paused: [Workstream] {
        filter({ $0.status == .paused })
    }
    
    var completed: [Workstream] {
        filter({ $0.status == .completed })
    }
}

enum SelectWorkstream: Hashable, Codable {
    case new
    case existing(Workstream.ID)
    case none
}

extension Workstream {
    enum Status:
        String,
        CustomStringConvertible,
        Codable,
        CaseIterable {
        case active, paused, completed
        var description: String { rawValue }
    }
}

struct Workstream: Codable, CustomStringConvertible, Identifiable {
    let id: UUID
    var title: String
    var issueKey: String?
    let created: Date
    var updated: Date
    var status: Status = .active
    private(set) var entries: [Entry]
    var workspaceId: Workspace.ID
    
//    var updates: [Update]
//    var plans: [Plan]
//    var dayPlans: [DayPlan]
    
    init(_ spaceId: Workspace.ID) {
        id = UUID()
        title = "New Workstream"
        let now = Date()
        created = now
        updated = now
        entries = []
        workspaceId = spaceId
    }
    
    var description: String {
        "\(issueKey == nil ? "" : "[\(issueKey!)] ")\(title)"
    }

    var active: Bool { status == .active }
    
    mutating func touch() {
        updated = Date()
    }
    
    mutating func addEntry(_ body: String) {
        let entry = Entry(
            workspaceId: workspaceId,
            workstreamId: self.id,
            body: body,
            number: (entries.last?.number ?? 0) + 1
        )
        entries.append(entry)
        touch()
    }
    
    mutating func deleteEntry(_ id: Entry.ID) {
        guard let index = entries.findIndex(id: id) else { return }
        entries.remove(at: index)
        touch()
    }
    
    func debug() {
        print("Workstream: \(id.uuidString)")
        print("Title: \(title)")
    }
}

extension Workstream {
    struct Entry: Codable, Identifiable {
        let id: UUID
        let number: Int
        let workspaceId: Workspace.ID
        let workstreamId: Workstream.ID
        var body: String
        let created: Date
        var updated: Date
        
        init(
            workspaceId: Workspace.ID,
            workstreamId: Workstream.ID,
            body: String,
            number: Int
        ) {
            id = UUID()
            self.body = body
            let now = Date()
            created = now
            updated = now
            self.number = number
            self.workspaceId = workspaceId
            self.workstreamId = workstreamId
        }
        
        var day: IsoDay { created.isoDay }
    }
}

extension [Workstream.Entry] {
    func findIndex(id: Workstream.Entry.ID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
}


extension Workstream {
    func entries(from rangeStart: Date, to rangeEnd: Date?) -> [Entry] {
        let end = rangeEnd ?? Date.distantFuture
        return entries.filter { $0.created >= rangeStart && $0.created <= end }
    }

    func entries(for stand: Standup) -> [Entry] {
        entries(from: stand.rangeStart, to: stand.rangeEnd)
    }
}
