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
        notDeleted.filter({ $0.status == .active })
    }
    
    var paused: [Workstream] {
        notDeleted.filter({ $0.status == .paused })
    }
    
    private var notDeleted: [Workstream] {
        filter({ $0.deleted == false })
    }
    
    private var deleted: [Workstream] {
        filter({ $0.deleted == true })
    }
    
    var completed: [Workstream] {
        notDeleted.filter({ $0.status == .completed })
    }
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
    var deleted = false
    
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
        let upd = Update(day: day, body: body)
        updates.append(upd)
    }
    
    mutating func deleteUpdate(_ update: Update) {
        guard let index = updates.firstIndex(
            where: { $0.id == update.id }
        ) else {
            return
        }
        updates[index].deleted = true
        updates[index].updated = Date()
    }
    
    mutating func deletePlan(_ plan: Plan) {
        guard let index = plans.firstIndex(
            where: { $0.id == plan.id }
        ) else {
            return
        }
        plans[index].deleted = true
        plans[index].updated = Date()
    }
    
    mutating func togglePlanComplete(
        _ planId: Workstream.Plan.ID,
        _ day: IsoDay?
    ) {
        if let i = plans.firstIndex(where: { $0.id == planId }) {
            plans[i].dayComplete = day
            plans[i].updated = Date()
        }
    }
    
    var logItems: [LogItem] {
        updates.all.map(\.logItem) + plans.all.map(\.logItem)
    }
    
    var logItemsByDay: [IsoDay: [LogItem]] {
        Dictionary(grouping: logItems, by: \.day)
    }
    
    var description: String {
        "\(issueKey == nil ? "" : "[\(issueKey!)] ")\(title)"
    }
    
    var daysWithLogItems: [IsoDay] {
        logItemsByDay.keys.sorted()
    }
    
    var updatesByDay: [IsoDay: [Update]] {
        Dictionary(grouping: updates.all, by: \.day)
    }
    
    var plansByDay: [IsoDay: [Plan]] {
        Dictionary(grouping: plans.all, by: \.dayAdded)
    }
}

extension Workstream {
    struct Update: Codable, Identifiable {
        let id: UUID
        let body: String
        let created: Date
        var updated: Date
        let day: IsoDay
        var deleted = false
        
        var standId: Standup.ID?
        var planId: Plan.ID?
        
        init(day: IsoDay, body: String) {
            id = UUID()
            self.body = body
            let now = Date()
            created = now
            updated = now
            self.day = day
        }
        
        var logItem: LogItem { return .update(self) }
    }
    
    struct Plan: Codable, Identifiable {
        let id: UUID
        let body: String
        let created: Date
        var updated: Date
        let dayAdded: IsoDay
        var dayComplete: IsoDay?
        var deleted = false
        var createdFromUpdateId: Workstream.Update.ID?

        init(_ day: IsoDay, body: String) {
            self.id = UUID()
            self.body = body
            let now = Date()
            self.created = now
            self.updated = now
            self.dayAdded = day
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
                d.created
            case let .plan(d):
                d.created
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
//    mutating func append(_ day: IsoDay, _ body: String) {
//        self.append(.init(day: day, body: body))
//    }
    
    var all: [Workstream.Update] {
        notDeleted
    }
    
    private var notDeleted: [Workstream.Update] {
        filter({ $0.deleted == false })
    }
    
    private func onOrAfter(_ day: IsoDay) -> [Workstream.Update] {
        self.filter({ $0.day >= day })
    }
    
    var noStandup: [Workstream.Update] {
        notDeleted.filter({ $0.standId == nil })
    }
    
    func findIndex(id: Workstream.Update.ID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
    
    func forStand(_ standId: Standup.ID) -> [Workstream.Update] {
        notDeleted.filter({ $0.standId == standId })
    }
    
    func forStandOrNoStand(_ standId: Standup.ID) -> [Workstream.Update] {
        notDeleted.filter({ $0.standId == standId || $0.standId == nil })
    }

//    private func notIn(_ stand: Standup) -> [Workstream.Update] {
//        self.filter({ !stand.wsUpdates.contains($0.id) })
//    }
    
//    func addedSince(_ stand: Standup?) -> [Workstream.Update] {
//        guard let stand else { return all }
//        return self.notDeleted.onOrAfter(stand.day).notIn(stand)
//    }
    
//    func includedInStand(_ stand: Standup) -> [Workstream.Update] {
//        notDeleted.filter({ stand.wsUpdates.contains($0.id) })
//    }
}

extension [Workstream.Plan] {
    mutating func append(_ day: IsoDay, _ body: String) {
        self.append(.init(day, body: body))
    }
        
    func find(id: Workstream.Plan.ID) -> Workstream.Plan? {
        first(where: { $0.id == id })
    }
    
    func findIndex(id: Workstream.Plan.ID) -> Int? {
        firstIndex(where: { $0.id == id })
    }

    var incomplete: [Workstream.Plan] {
        all.filter({ $0.dayComplete == nil })
    }
    
    var complete: [Workstream.Plan] {
        all.filter({ $0.dayComplete != nil })
    }
    
    var all: [Workstream.Plan] {
        nonDeleted
    }
    
    private var nonDeleted: [Workstream.Plan] {
        filter({ $0.deleted == false })
    }
    
    private func completedOnOrAfter(_ day: IsoDay) -> [Workstream.Plan] {
        self.complete.filter({
            guard let dc = $0.dayComplete else {
                return false
            }
            return dc >= day
        })
    }
    
//    private func notIn(_ stand: Standup) -> [Workstream.Plan] {
//        self.filter({ !stand.wsPlans.contains($0.id) })
//    }
    
//    func completedSince(_ stand: Standup?) -> [Workstream.Plan] {
//        guard let stand else { return complete }
//        return nonDeleted.completedOnOrAfter(stand.day).notIn(stand)
//    }
}


enum SelectWorkstream: Hashable, Codable {
    case new
    case existing(Workstream.ID)
    case none
}
