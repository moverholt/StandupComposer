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
    let day: IsoDay
    var title: String
    let created: Date
    var updated: Date
    
    var prevDay: [WorkstreamGenUpdate]
    var today: [WorkstreamGenUpdate]
    
    var formattedSlack: String?
    
    private(set) var status: Status = .edit
    
    init(_ day: IsoDay) {
        self.init(day, title: "New Standup")
    }

    init(_ day: IsoDay, title: String) {
        id = UUID()
        self.day = day
        self.title = title
        let now = Date()
        created = now
        updated = now
        prevDay = []
        today = []
    }
    
    var editing: Bool { status == .edit }
    var published: Bool { status == .published }
    
    mutating func publish() {
        status = .published
    }
    
    mutating func addWorkstream(_ stream: Workstream) {
        let upd = Standup.WorkstreamGenUpdate(stream)
        prevDay.append(upd)
        let pln = Standup.WorkstreamGenUpdate(stream)
        today.append(pln)
    }
}

extension Standup {
    enum Status: String, CustomStringConvertible, Codable, CaseIterable {
        case edit, published
        var description: String { self.rawValue }
    }
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

