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
//        let upd = Standup.WorkstreamGenUpdate(stream)
//        prevDay.append(upd)
//        
//        streamUpdates[stream.id] = .init(stream)
    }
    
//    mutating func addWorkstreamToPlans(_ stream: Workstream) {
//        let pln = Standup.WorkstreamGenUpdate(stream)
//        today.append(pln)
//        
//        incompletePlans[stream.id] = []
//        for p in stream.plans.incomplete {
//            incompletePlans[stream.id]?.insert(p.id)
//        }
//    }

//    mutating func removeWorkstreamFromUpdates(_ streamId: Workstream.ID) {
//        streamUpdates[streamId] = nil
//    }
//    
//    mutating func removeWorkstreamFromPlans(_ streamId: Workstream.ID) {
//        incompletePlans[streamId] = nil
//    }
//
//    func debug() {
//        print("==== Standup: \(id.uuidString) ====")
//        print("Previous stand ID: \(previousStandId?.uuidString ?? "None")")
//        for (_, strUpd) in streamUpdates {
//            print("Stream: \(strUpd.ws.title)")
//            print("Last update number: \(strUpd.lastUpdateNumber)")
//            print("Last plan number: \(strUpd.lastPlanNumber)")
//        }
//        print("==== ====")
//    }
}

extension Standup {
    enum Status: String, CustomStringConvertible, Codable, CaseIterable {
        case edit, published
        var description: String { self.rawValue }
    }
    
//    enum Section {
//        case prevDay
//        case today
//    }
    
//    func hasWorkstreamInPlan(_ streamId: Workstream.ID) -> Bool {
//        incompletePlans[streamId] != nil
////        let array = section == .prevDay ? prevDay : today
////        return array.contains(where: { $0.ws.id == workstreamId })
//    }
    
//    func hasWorkstreamInUpdates(_ streamId: Workstream.ID) -> Bool {
//        streamUpdates[streamId] != nil
//    }
    
//    func hasWorkstream(_ streamId: Workstream.ID, in section: Section) -> Bool {
//        switch section {
//        case .prevDay:
//            hasWorkstreamInUpdates(streamId)
//        case .today:
//            hasWorkstreamInPlan(streamId)
//        }
//    }
    
    mutating func touch() { updated = Date() }
    
//    mutating func addWorkstream(_ stream: Workstream, to section: Section) {
//        let upd = Standup.WorkstreamGenUpdate(stream)
//        switch section {
//        case .prevDay:
//            addWorkstreamToUpdates(stream)
//            prevDay.append(upd)
//        case .today:
//            today.append(upd)
//            addWorkstreamToPlans(stream)
//        }
//        touch()
//    }
    
//    mutating func removeWorkstream(_ streamId: Workstream.ID, from section: Section) {
//        switch section {
//        case .prevDay:
//            if let index = prevDay.firstIndex(where: { $0.ws.id == streamId }) {
//                prevDay.remove(at: index)
//            }
//            removeWorkstreamFromUpdates(streamId)
//        case .today:
//            if let index = today.firstIndex(where: { $0.ws.id == streamId }) {
//                today.remove(at: index)
//            }
//            removeWorkstreamFromPlans(streamId)
//        }
//        
//        
//        touch()
//    }
    
//    mutating func addPrevPlan() {
//    }
    
//    mutating func addUpdate(_ body: String, _ streamId: Workstream.ID?) {
//        let upd = Update(body, streamId: streamId)
//        updates.append(upd)
//        touch()
//    }
    
//    mutating func addPlan(_ body: String, _ streamId: Workstream.ID?) {
//        let pln = Plan(body, streamId: streamId)
//        plans.append(pln)
//        touch()
//    }
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
    
//    struct PrevPlan: Codable, Identifiable {
//        let id: UUID
//        let planId: Plan.ID
//        let planBody: String
//        var streamId: Workstream.ID?
//        var completed: Bool
//        var notes: String
//    }
//    
//    struct Update: Codable, Identifiable {
//        let id: UUID
//        let body: String
//        var streamId: Workstream.ID?
//        let created: Date
//        var updated: Date
//
//        init(_ body: String, streamId: Workstream.ID?) {
//            id = UUID()
//            self.body = body
//            self.streamId = streamId
//            let now = Date()
//            created = now
//            updated = now
//        }
//    }
    
//    struct Plan: Codable, Identifiable {
//        let id: UUID
//        let body: String
//        let streamId: Workstream.ID?
//        
//        init(_ body: String, streamId: Workstream.ID?) {
//            id = UUID()
//            self.body = body
//            self.streamId = streamId
//        }
//    }
//    
//    struct WorkstreamMarker: Codable {
//        let ws: WorkstreamGenUpdate.WorkstreamMeta
//        let lastUpdateNumber: Int
//        let lastPlanNumber: Int
//        
//        init(_ stream: Workstream) {
//            ws = WorkstreamGenUpdate.WorkstreamMeta(stream)
//            lastUpdateNumber = stream.lastUpdateNumber ?? 0
//            lastPlanNumber = stream.lastPlanNumber ?? 0
//        }
//    }
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
    }
}
