//
//  Workspace.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/2/26.
//

import Foundation
import Playgrounds

struct Workspace: Codable, CustomStringConvertible, Identifiable  {
    var meta: Meta
    var streams: [Workstream]
    var stands: [Standup]
    
    struct Meta: Codable, Identifiable {
        let id: UUID
        var title: String
    }

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
    
    mutating func publish(standId id: Standup.ID) {
        guard let index = stands.findIndex(id: id) else { return }
        stands[index].publish()
    }
    
    mutating func addWorkstreamUpdate(
        id: Workstream.ID,
        body: String,
        standId: Standup.ID?
    ) {
        guard let index = streams.findIndex(id: id) else { return }
        var update = Workstream.Update(.today, body: body)
        update.standId = standId
        streams[index].updates.append(update)
    }
    
    mutating func addWorkstreamPlan(
        id: Workstream.ID,
        body: String,
        standId: Standup.ID?
    ) {
        guard let index = streams.findIndex(id: id) else { return }
        var plan = Workstream.Plan(.today, body: body)
        if let id = standId {
            plan.standIds.append(id)
        }
        streams[index].plans.append(plan)
    }
    
    mutating func createStandup(_ title: String) -> Standup {
        var stand = Standup(.today, title: title)
        
        for i in 0..<streams.count {
            let stream = streams[i]
            let upd = Standup.WorkstreamGenUpdate(stream)
            stand.prevDay.append(upd)
            let pln = Standup.WorkstreamGenUpdate(stream)
            stand.today.append(pln)
            
            for upd in stream.updates.noStandup {
                if let i2 = stream.updates.findIndex(id: upd.id) {
                    streams[i].updates[i2].standId = stand.id
                }
            }
            
            for pln in stream.plans.complete.noCompletedStandId {
                if let i2 = stream.plans.findIndex(id: pln.id) {
                    streams[i].plans[i2].completedStandId = stand.id
                }
            }
            
            for pln in stream.plans.incomplete {
                if let i2 = stream.plans.findIndex(id: pln.id) {
                    streams[i].plans[i2].standIds.append(stand.id)
                }
            }
        }
        stands.append(stand)
        return stand
    }

    mutating func deleteStand(_ id: Standup.ID) {
        guard let index = stands.findIndex(id: id) else { return }
        stands.remove(at: index)
    }
    
    mutating func deleteWorkstream(_ id: Workstream.ID) {
        guard let index = streams.findIndex(id: id) else { return }
        streams.remove(at: index)
    }
}

#Playground {
    var space = Workspace()
    var ws1 = Workstream()
    ws1.title = "Add pasta types"
    ws1.appendUpdate(.today, body: "I did something")
    
    let pl1 = Workstream.Plan(.today, body: "I will do something")
    ws1.plans.append(pl1)
    
    space.streams.append(ws1)
    
    let _ = space.createStandup("Today's Standup")
}
