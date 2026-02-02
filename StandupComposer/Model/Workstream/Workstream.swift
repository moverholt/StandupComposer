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
//        updates = []
//        plans = []
//        dayPlans = []
    }
    
    var description: String {
        "\(issueKey == nil ? "" : "[\(issueKey!)] ")\(title)"
    }
    
//    var updatesByDay: [IsoDay: [Update]] {
//        Dictionary(grouping: updates, by: \.day)
//    }
    
    var active: Bool { status == .active }
    
//    var lastUpdateNumber: Int? { updates.last?.number }
//    var nextUpdateNumber: Int { (lastUpdateNumber ?? 0) + 1 }
    
//    var lastPlanNumber: Int? { plans.last?.number }
//    var nextPlanNumber: Int { (lastPlanNumber ?? 0) + 1 }
    
//    mutating func appendUpdate(_ day: IsoDay, body: String) {
//        let upd = Update(day, body: body, number: nextUpdateNumber)
//        updates.append(upd)
//    }
//    
//    mutating func deleteUpdate(_ id: Update.ID) {
//        guard let index = updates.findIndex(id: id) else { return }
//        updates.remove(at: index)
//    }
//    
//    mutating func appendPlan(_ body: String) -> Plan.ID {
//        let plan = Plan(.today, body: body, number: nextPlanNumber)
//        plans.append(plan)
//        touch()
//        return plan.id
//    }
    
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
    
//    mutating func deletePlan(_ id: Plan.ID) {
//        guard let index = plans.findIndex(id: id) else { return }
//        plans.remove(at: index)
//    }
    
//    mutating func togglePlanComplete(
//        _ planId: Workstream.Plan.ID,
//        _ day: IsoDay?
//    ) {
//        if let i = plans.firstIndex(where: { $0.id == planId }) {
//            plans[i].dayComplete = day
//            plans[i].updated = Date()
//        }
//    }
    
//    mutating func updatePlanComplete(
//        _ value: Bool,
//        _ planId: Workstream.Plan.ID,
//        _ standId: Standup.ID?,
//    ) {
//        if let i = plans.firstIndex(where: { $0.id == planId }) {
//            if !value {
//                plans[i].dayComplete = nil
//                plans[i].completedStandId = nil
//                plans[i].updated = Date()
//
//            } else {
//                plans[i].dayComplete = .today
//                plans[i].completedStandId = standId
//                plans[i].updated = Date()
//            }
//        }
//
//    }
    
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
    }
    
//    struct Plan: Codable, Identifiable {
//        let id: UUID
//        let number: Int
//        let body: String
//        let created: Date
//        var updated: Date
//        let dayAdded: IsoDay
//        var dayComplete: IsoDay?
//        
//        var completedStandId: Standup.ID?
//        var standIds: [Standup.ID]
//        
//        init(_ day: IsoDay, body: String, number: Int) {
//            self.id = UUID()
//            self.number = number
//            self.body = body
//            let now = Date()
//            self.created = now
//            self.updated = now
//            self.dayAdded = day
//            self.dayComplete = nil
//            self.standIds = []
//        }
//        
//        var completed: Bool { dayComplete != nil }
//    }
    
//    struct DayPlan: Codable, Identifiable {
//        let id: UUID
//        let day: IsoDay
//        let planId: Plan.ID
//        var body: String
//        var update: String
//        var completed: Bool
//    }
}

extension [Workstream.Entry] {
//extension [Workstream.Update] {
//    private func onOrAfter(_ day: IsoDay) -> [Workstream.Update] {
//        self.filter({ $0.day >= day })
//    }
//    
//    var noStandup: [Workstream.Update] {
//        filter({ $0.standId == nil })
//    }
//    
    func findIndex(id: Workstream.Entry.ID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
//    
//    func forStand(_ standId: Standup.ID) -> [Workstream.Update] {
//        filter({ $0.standId == standId })
//    }
}

//extension [Workstream.Plan] {
////    mutating func append(_ day: IsoDay, _ body: String) {
////        self.append(.init(day, body: body))
////    }
//        
//    func find(id: Workstream.Plan.ID) -> Workstream.Plan? {
//        first(where: { $0.id == id })
//    }
//    
//    func findIndex(id: Workstream.Plan.ID) -> Int? {
//        firstIndex(where: { $0.id == id })
//    }
//
//    var incomplete: [Workstream.Plan] {
//        filter({ $0.dayComplete == nil })
//    }
//    
//    var complete: [Workstream.Plan] {
//        filter({ $0.dayComplete != nil })
//    }
//    
//    var noCompletedStandId: [Workstream.Plan] {
//        filter({ $0.completedStandId == nil })
//    }
//    
//    func forStand(_ standId: Standup.ID) -> [Workstream.Plan] {
//        filter({ $0.standIds.contains(standId) })
//    }
//    
//    func completedForStand(_ standId: Standup.ID) -> [Workstream.Plan] {
//        filter({ $0.completedStandId == standId })
//    }
//}
