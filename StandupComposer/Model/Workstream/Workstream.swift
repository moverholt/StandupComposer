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
    
    var deleted: [Workstream] {
        filter({ $0.status == .deleted })
    }
    
    var completed: [Workstream] {
        filter({ $0.status == .completed })
    }
}

extension Workstream {
    enum Status:
        String,
        CustomStringConvertible,
        Codable,
        CaseIterable,
        Identifiable {
        case active, paused, completed, deleted
        var description: String { rawValue }
        var id: String { rawValue }
    }
}

struct Workstream: Codable, CustomStringConvertible, Identifiable {
    let id: UUID
    var title: String
    var issueKey: String?
    let created: Date
    var updated: Date
    var status: Status = .active
    
    var updates: [Update]
    var plans: [Plan]
    
    var logs: [LogItem] {
        let items = plans.map(\.logItem) + updates.map(\.logItem)
        return items.sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    init() {
        id = UUID()
        title = "New Workstream"
        let now = Date()
        created = now
        updated = now
        updates = []
        plans = []
    }
    
    mutating func appendUpdate(_ day: IsoDay, body: String) {
        updates.append(day, body)
    }
    
    mutating func deleteUpdate(_ update: Update) {
        guard let index = updates.firstIndex(
            where: { $0.id == update.id }
        ) else {
            return
        }
        updates[index].deleted = true
        updates[index].updatedAt = Date()
    }
    
    var updatesByDay: [IsoDay: [Update]] {
        Dictionary(grouping: updates.available, by: \.day)
    }
    
    var description: String {
        "\(issueKey == nil ? "" : "[\(issueKey!)] ")\(title)"
    }
    
    var daysWithUpdates: [IsoDay] {
        updatesByDay.keys.sorted()
    }
}

extension Workstream {
    struct Update: Codable, Identifiable {
        let id: UUID
        let body: String
        let createdAt: Date
        var updatedAt: Date
        let day: IsoDay
        var deleted = false
        
        init(day: IsoDay, body: String) {
            self.id = UUID()
            self.body = body
            let now = Date()
            self.createdAt = now
            self.updatedAt = now
            self.day = day
        }
        
        var logItem: LogItem { return .update(self) }
    }
    
    struct Plan: Codable, Identifiable {
        let id: UUID
        let body: String
        let createdAt: Date
        var updatedAt: Date
        let dayAdded: IsoDay
        var dayComplete: IsoDay?
        var deleted = false
        var createdFromUpdateId: Workstream.Update.ID?

        init(body: String) {
            self.id = UUID()
            self.body = body
            let now = Date()
            self.createdAt = now
            self.updatedAt = now
            self.dayAdded = .today
            self.dayComplete = nil
        }
        
        var logItem: LogItem { return .plan(self) }
    }
    
    enum LogItem {
        case update(Workstream.Update)
        case plan(Workstream.Plan)
        
        var createdAt: Date {
            switch self {
            case let .update(d):
                d.createdAt
            case let .plan(d):
                d.createdAt
            }
        }
        
        var day: IsoDay {
            switch self {
            case let .update(d):
                d.day
            case let .plan(d):
                d.dayAdded
            }
        }
    }
}

extension [Workstream.Update] {
    mutating func append(_ day: IsoDay, _ body: String) {
        self.append(.init(day: day, body: body))
    }
    
    var available: [Workstream.Update] {
        filter({ $0.deleted == false })
    }
}


enum SelectWorkstream: Hashable, Codable {
    case new
    case existing(Workstream.ID)
    case none
}
