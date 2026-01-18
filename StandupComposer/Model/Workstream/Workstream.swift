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
    
    var updates: [Update]
    var plans: [Plan]
    
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
        let upd = Update(day, body: body)
        updates.append(upd)
    }
    
    mutating func deleteUpdate(_ id: Update.ID) {
        guard let index = updates.findIndex(id: id) else { return }
        updates.remove(at: index)
    }
    
    mutating func appendPlan(_ body: String) {
        let plan = Plan(.today, body: body)
        plans.append(plan)
    }
    
    mutating func deletePlan(_ id: Plan.ID) {
        guard let index = plans.findIndex(id: id) else { return }
        plans.remove(at: index)
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
    
    var description: String {
        "\(issueKey == nil ? "" : "[\(issueKey!)] ")\(title)"
    }
    
    var updatesByDay: [IsoDay: [Update]] {
        Dictionary(grouping: updates, by: \.day)
    }
}

extension Workstream {
    struct Update: Codable, Identifiable {
        let id: UUID
        let body: String
        let created: Date
        var updated: Date
        let day: IsoDay
        
        var standId: Standup.ID?
        
        init(_ day: IsoDay, body: String) {
            id = UUID()
            self.body = body
            let now = Date()
            created = now
            updated = now
            self.day = day
        }
    }
    
    struct Plan: Codable, Identifiable {
        let id: UUID
        let body: String
        let created: Date
        var updated: Date
        let dayAdded: IsoDay
        var dayComplete: IsoDay?
        
        var completedStandId: Standup.ID?
        var standIds: [Standup.ID]
        
        init(_ day: IsoDay, body: String) {
            self.id = UUID()
            self.body = body
            let now = Date()
            self.created = now
            self.updated = now
            self.dayAdded = day
            self.dayComplete = nil
            self.standIds = []
        }
    }
}

extension [Workstream.Update] {
    private func onOrAfter(_ day: IsoDay) -> [Workstream.Update] {
        self.filter({ $0.day >= day })
    }
    
    var noStandup: [Workstream.Update] {
        filter({ $0.standId == nil })
    }
    
    func findIndex(id: Workstream.Update.ID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
    
    func forStand(_ standId: Standup.ID) -> [Workstream.Update] {
        filter({ $0.standId == standId })
    }
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
        filter({ $0.dayComplete == nil })
    }
    
    var complete: [Workstream.Plan] {
        filter({ $0.dayComplete != nil })
    }
    
    var noCompletedStandId: [Workstream.Plan] {
        filter({ $0.completedStandId == nil })
    }
    
    func forStand(_ standId: Standup.ID) -> [Workstream.Plan] {
        filter({ $0.standIds.contains(standId) })
    }
    
    func completedForStand(_ standId: Standup.ID) -> [Workstream.Plan] {
        filter({ $0.completedStandId == standId })
    }
}
