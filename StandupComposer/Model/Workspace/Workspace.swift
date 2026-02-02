//
//  Workspace.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/2/26.
//

import Foundation
import Playgrounds

struct Workspace: Codable, Identifiable  {
    private(set) var meta: Meta
    private(set) var streams: [Workstream]
    private(set) var stands: [Standup]

    init() {
        meta = Meta(id: UUID(), title: "New Workspace")
        streams = []
        stands = []
    }

    init(meta: Meta, streams: [Workstream], stands: [Standup]) {
        self.meta = meta
        self.streams = streams
        self.stands = stands
    }
    
    var id: UUID { meta.id }
    
    var description: String { meta.title }
    
    var editingStandup: Standup? { stands.editing.last }
    
    var isEditingStandup: Bool { editingStandup != nil }
    
    var standupById: [Standup.ID: Standup] {
        Dictionary(uniqueKeysWithValues: stands.map { ($0.id, $0) })
    }
    
    mutating func publishStandup(_ id: Standup.ID) {
        guard let index = stands.findIndex(id: id) else { return }
        stands[index].publish()
        stands[index].updated = Date()
    }
    
    mutating func updateWorkstream(_ stream: Workstream) {
        if let index = streams.findIndex(id: stream.id) {
            streams[index] = stream
        }
    }
    
//    mutating func addWorkstreamUpdate(
//        id: Workstream.ID,
//        body: String,
//        standId: Standup.ID?
//    ) {
////        appendUpdate(body, streamId: id)
////        if let stream = getStream(id),
////           let standId = standId,
////           let standIndex = stands.findIndex(id: standId) {
////            stands[standIndex].streamUpdates[id] = .init(stream)
////        }
//    }
    
    mutating func deleteWorkstreamEntry(_ entry: Workstream.Entry) {
        if let index = streams.findIndex(id: entry.workstreamId) {
            streams[index].deleteEntry(entry.id)
        }
    }
    
//    mutating func addWorkstreamPlan(
//        id: Workstream.ID,
//        body: String,
//        standId: Standup.ID?
//    ) {
//        let plnId = appendPlan(body, streamId: id)
//        if let standId = standId,
//           let standIndex = stands.findIndex(id: standId) {
//            if stands[standIndex].incompletePlans[id] == nil {
//                stands[standIndex].incompletePlans[id] = Set()
//            }
//            stands[standIndex].incompletePlans[id]?.insert(plnId)
//        }
//    }
    
    mutating func createWorkstream(_ title: String) -> Workstream.ID {
        return createWorkstream(title, nil)
    }
    
    mutating func createWorkstream(
        _ title: String,
        _ key: String?
    ) -> Workstream.ID {
        var stream = Workstream(self.id)
        stream.title = title
        stream.issueKey = key
        streams.append(stream)
        return stream.id
    }
    
    mutating func addWorkstreamEntry(
        _ streamId: Workstream.ID,
        _ body: String
    ) {
        if let index = streams.findIndex(id: streamId) {
            streams[index].addEntry(body)
        }
    }
    
    mutating func createStandup(_ title: String) -> Standup.ID {
        let previousStand = stands.published.last
        var stand = Standup(
            title,
            self.id,
            start: previousStand?.rangeEnd ?? Date.distantPast,
            previousStandId: previousStand?.id
        )
        
        for stream in streams.active {
            let _ = stand.addWorkstream(stream)
        }
        
        stands.append(stand)
        return stand.id
//
//        for i in 0..<streams.count {
//            let stream = streams[i]
//            if !stream.active { continue }
////            let upd = Standup.WorkstreamGenUpdate(stream)
////            stand.prevDay.append(upd)
////            let pln = Standup.WorkstreamGenUpdate(stream)
////            stand.today.append(pln)
//            
//            stand.addWorkstreamToUpdates(stream)
//            stand.addWorkstreamToPlans(stream)
//            
////            for upd in stream.updates.noStandup {
////                if let i2 = stream.updates.findIndex(id: upd.id) {
////                    streams[i].updates[i2].standId = stand.id
////                }
////            }
////            
////            for pln in stream.plans.complete.noCompletedStandId {
////                if let i2 = stream.plans.findIndex(id: pln.id) {
////                    streams[i].plans[i2].completedStandId = stand.id
////                }
////            }
////            
////            for pln in stream.plans.incomplete {
////                if let i2 = stream.plans.findIndex(id: pln.id) {
////                    streams[i].plans[i2].standIds.append(stand.id)
////                }
////            }
//        }
//        stands.append(stand)
//        return stand.id
    }
    
    mutating func updateStandup(_ stand: Standup) {
        if let index = stands.findIndex(id: stand.id) {
            stands[index] = stand
        }
    }

    mutating func deleteStand(_ id: Standup.ID) {
        guard let index = stands.findIndex(id: id) else { return }
        stands.remove(at: index)
    }
    
    mutating func deleteWorkstream(_ id: Workstream.ID) {
        guard let index = streams.findIndex(id: id) else { return }
        streams.remove(at: index)
    }
    
//    mutating func setStandTitle(_ id: Standup.ID, _ title: String) {
//        guard let index = stands.findIndex(id: id) else { return }
//        stands[index].title = title
//        stands[index].updated = Date()
//    }
    
    func getStand(_ id: Standup.ID?) -> Standup? {
        guard let id = id else { return nil }
        return stands.find(id: id)
    }
    
    func getStream(_ id: Workstream.ID?) -> Workstream? {
        guard let id else { return nil }
        return streams.first(where: { $0.id == id })
    }
    
//    func getStandStreamUpdates(
//        standId: Standup.ID
//    ) -> [Workstream.ID: [Workstream.Update]] {
//        guard let stand = getStand(standId) else { return [:] }
//        let prev = getStand(stand.previousStandId)
//        
//        var resp: [Workstream.ID: [Workstream.Update]] = [:]
//        for (_, marker) in stand.streamUpdates {
//            let firstUpdateNumber = prev?.streamUpdates[marker.ws.id]?.lastUpdateNumber ?? 0
//            if let stream = streams.find(id: marker.ws.id) {
//                resp[stream.id] = stream.updates.filter({
//                    $0.number > firstUpdateNumber &&
//                    $0.number <= marker.lastUpdateNumber
//                })
//            }
//        }
//        
//        return resp
//    }
    
//    func getStandCompletedPlans(
//        standId: Standup.ID
//    ) -> [Workstream.ID: [Workstream.Plan]] {
//        guard let stand = stands.find(id: standId) else { return [:] }
//        var resp: [Workstream.ID: [Workstream.Plan]] = [:]
//        
//        if let prev = getStand(stand.previousStandId) {
//            for (streamId, planIds) in prev.incompletePlans {
//                if let stream = streams.find(id: streamId) {
//                    for planId in planIds {
//                        if let plan = stream.plans.find(id: planId), plan.completed {
//                            resp[streamId] = (resp[streamId] ?? []) + [plan]
//                        }
//                    }
//                }
//            }
////            for (streamId, planIds) in stand.incompletePlans {
////                if let stream = streams.find(id: streamId) {
////                    for planId in planIds {
////                        if let plan = stream.plans.find(id: planId), plan.completed {
////                            if !(resp[streamId] ?? []).contains(where: { $0.id == plan.id }) {
////                                resp[streamId] = (resp[streamId] ?? []) + [plan]
////                            }
////                        }
////                    }
////                }
////            }
//        } else {
//            for (_, marker) in stand.streamUpdates {
//                if let stream = streams.find(id: marker.ws.id) {
//                    resp[stream.id] = stream.plans.filter({ $0.completed })
//                }
//            }
//        }
//        
//        return resp
//    }
    
//    func getStandIncompletePlans(
//        standId: Standup.ID
//    ) -> [Workstream.ID: [Workstream.Plan]] {
//        guard let stand = stands.find(id: standId) else { return [:] }
//        
//        var resp: [Workstream.ID: [Workstream.Plan]] = [:]
//        for (_, marker) in stand.streamUpdates {
//            if let stream = streams.find(id: marker.ws.id) {
//                resp[stream.id] = stream.plans.filter({ !$0.completed })
//            }
//        }
//        
//        return resp
//    }

//    mutating func appendUpdate(_ body: String, streamId: Workstream.ID) {
//        guard let index = streams.findIndex(id: streamId) else { return }
//        streams[index].appendUpdate(.today, body: body)
//        streams[index].touch()
//    }
    
//    mutating func appendPlan(
//        _ body: String,
//        streamId: Workstream.ID
//    ) -> Workstream.Plan.ID {
//        let index = streams.findIndex(id: streamId)!
//        let id = streams[index].appendPlan(body)
//        streams[index].touch()
//        return id
//    }
    
//    mutating func completePlan(
//        _ planId: Workstream.Plan.ID,
//        streamId: Workstream.ID
//    ) {
//        let streamIndex = streams.findIndex(id: streamId)!
//        let planIndex = streams[streamIndex].plans.findIndex(id: planId)!
//        streams[streamIndex].plans[planIndex].dayComplete = .today
//        streams[streamIndex].touch()
//    }
    
//    mutating func updatePlanComplete(
//        _ value: Bool,
//        planId: Workstream.Plan.ID,
//        streamId: Workstream.ID,
//        standId: Standup.ID?
//    ) {
//        
//        let streamIndex = streams.findIndex(id: streamId)!
//        let planIndex = streams[streamIndex].plans.findIndex(id: planId)!
//        if value {
//            streams[streamIndex].plans[planIndex].dayComplete = .today
//        } else {
//            streams[streamIndex].plans[planIndex].dayComplete = nil
//        }
//        streams[streamIndex].touch()
//        
//        if let id = standId {
//            if let i = stands.findIndex(id: id) {
//                if value {
//                    stands[i].incompletePlans[streamId]?.remove(planId)
//                } else {
//                    if stands[i].incompletePlans[streamId] == nil {
//                        stands[i].incompletePlans[streamId] = Set()
//                    }
//                    stands[i].incompletePlans[streamId]?.insert(planId)
//                }
//            }
//        }
//    }
}

extension Workspace {
    struct Meta: Codable, Identifiable {
        let id: UUID
        var title: String
    }
}

#Playground {
    var space = Workspace()

    var ws1 = Workstream(UUID())
    ws1.title = "Add pasta types"
//    ws1.appendUpdate(.today, body: "I did something")
//    ws1.appendUpdate(.today, body: "I did something else")
//    
//    space.streams.append(ws1)
//    let pln1Id = space.appendPlan("Something I will do", streamId: ws1.id)
//    let pln2Id = space.appendPlan("Something else I will do", streamId: ws1.id)
//    
//    space.updatePlanComplete(true, planId: pln2Id, streamId: ws1.id, standId: nil)
//
//    let s1Id = space.createStandup("First Standup")
//    
//    space.appendUpdate("Something I did after last standup", streamId: ws1.id)
//    
//    let upds = space.getStandStreamUpdates(standId: s1Id)
//    let compPlns = space.getStandCompletedPlans(standId: s1Id)
//    let incompPlns = space.getStandIncompletePlans(standId: s1Id)
//    
//    let pln3Id = space.appendPlan("Something even newer", streamId: ws1.id)
//    space.appendUpdate("Talked to someone", streamId: ws1.id)
//    space.updatePlanComplete(true, planId: pln1Id, streamId: ws1.id, standId: nil)
//    
//    let s2Id = space.createStandup("Second Standup")
//    
//    let upds2 = space.getStandStreamUpdates(standId: s2Id)
//    let compPlns2 = space.getStandCompletedPlans(standId: s2Id)
//    let incompPlns2 = space.getStandIncompletePlans(standId: s2Id)
     
//    let pl1 = Workstream.Plan(.today, body: "I will do something", number: 1)
//    ws1.plans.append(pl1)
//    
//    space.streams.append(ws1)
//    
//    let _ = space.createStandup("Today's Standup")
}
