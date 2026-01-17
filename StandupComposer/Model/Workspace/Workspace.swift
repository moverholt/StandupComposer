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
        meta.title = "New Workspace"
        self.streams = []
        self.stands = []
    }

    init(meta: Meta, streams: [Workstream], stands: [Standup]) {
        self.meta = meta
        self.streams = streams
        self.stands = stands
    }
    
    var id: UUID { meta.id }
    
    var description: String { meta.title }
    
    var previousStandup: Standup? {
        stands.published.max { $0.created < $1.created }
    }
    
    mutating func publish(standId id: Standup.ID) {
        print("Publish called with id: \(id)")
        guard let index = stands.findIndex(id: id) else {
            return
        }
        stands[index].publish()
    }
    
    mutating func addWorkstreamUpdate(
        id: Workstream.ID,
        body: String,
        standId: Standup.ID?
    ) {
        guard let index = streams.findIndex(id: id) else { return }
        var update = Workstream.Update(day: .today, body: body)
        update.standId = standId
        streams[index].updates.append(update)
    }
    
    mutating func createStandup(_ title: String) -> Standup {
        var stand = Standup(.today, title: title)
        
        for i in 0..<streams.count {
            let stream = streams[i]
            let upd = Standup.WorkstreamGenUpdate(stream)
            stand.prevDay.append(upd)
            let pln = Standup.WorkstreamGenUpdate(stream)
            stand.today.append(pln)
            
            if let ps = previousStandup {
                for upd in stream.updates.noStandup {
                    if let i2 = stream.updates.findIndex(id: upd.id) {
                        streams[i].updates[i2].standId = stand.id
                    }
                }
//                for pln in stream.plans.completedSince(ps) {
//                    stand.wsPlans.append(pln.id)
//                }
            } else {
                for upd in stream.updates.noStandup {
                    if let i2 = stream.updates.findIndex(id: upd.id) {
                        streams[i].updates[i2].standId = stand.id
                    }
                }
//                for pln in stream.plans.incomplete {
//                    stand.wsPlans.append(pln.id)
//                }
            }
        }
        stands.append(stand)
        return stand
    }
    
    
//    func workstreamUpdatesNotInStandup(
//        _ streamId: Workstream.ID
//    ) -> [Workstream.Update] {
//        guard let ws = streams.find(id: streamId) else {
//            return []
//        }
//        ws.updates.noStandup
//    }
}

#Playground {
    var space = Workspace()
    var ws1 = Workstream()
    ws1.title = "Add pasta types"
    ws1.appendUpdate(.today, body: "I did something")
    
    var pl1 = Workstream.Plan(.today, body: "I will do something")
    ws1.plans.append(pl1)
    
    space.streams.append(ws1)
    
    let stand = space.createStandup("Today's Standup")
}
