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
    
    mutating func deleteWorkstreamEntry(_ entry: Workstream.Entry) {
        if let index = streams.findIndex(id: entry.workstreamId) {
            streams[index].deleteEntry(entry.id)
        }
    }
    
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
    
    mutating func createStandup(
        _ title: String,
        start: Date = Date.distantPast
    ) -> Standup.ID {
        let previousStand = stands.published.last
        let startDate = start != Date.distantPast ? start : (previousStand?.rangeEnd ?? Date.distantPast)
        var stand = Standup(
            title,
            self.id,
            start: startDate,
            previousStandId: previousStand?.id
        )
        
        for stream in streams.active {
            let _ = stand.addWorkstream(stream)
        }
        
        stands.append(stand)
        return stand.id
    }
    
    mutating func updateStandup(_ stand: Standup) {
        if let index = stands.findIndex(id: stand.id) {
            stands[index] = stand
        }
    }

    mutating func setMinus24Draft(standId: Standup.ID, entryId: Standup.WorkstreamEntry.ID, draft: String) {
        guard var st = getStand(standId),
              let idx = st.entries.firstIndex(where: { $0.id == entryId })
        else { return }
        st.entries[idx].minus24Draft = draft
        st.entries[idx].minus24DraftGeneratedAt = Date()
        updateStandup(st)
    }

    mutating func setPlus24Draft(standId: Standup.ID, entryId: Standup.WorkstreamEntry.ID, draft: String) {
        guard var st = getStand(standId),
              let idx = st.entries.firstIndex(where: { $0.id == entryId })
        else { return }
        st.entries[idx].plus24Draft = draft
        st.entries[idx].plus24DraftGeneratedAt = Date()
        updateStandup(st)
    }
    
    mutating func setFormatted(standId: Standup.ID, formatted: String) {
        guard var st = getStand(standId) else { return }
        st.formattedSlack = formatted
        updateStandup(st)
    }

    mutating func setEntryReviewed(standId: Standup.ID, entryId: Standup.WorkstreamEntry.ID, reviewed: Bool) {
        guard var st = getStand(standId),
              let idx = st.entries.firstIndex(where: { $0.id == entryId })
        else { return }
        st.entries[idx].reviewedAt = reviewed ? Date() : nil
        updateStandup(st)
    }

    mutating func deleteStand(_ id: Standup.ID) {
        guard let index = stands.findIndex(id: id) else { return }
        stands.remove(at: index)
    }
    
    mutating func deleteWorkstream(_ id: Workstream.ID) {
        guard let index = streams.findIndex(id: id) else { return }
        streams.remove(at: index)
    }
    
    func getStand(_ id: Standup.ID?) -> Standup? {
        guard let id = id else { return nil }
        return stands.find(id: id)
    }
    
    func getStream(_ id: Workstream.ID?) -> Workstream? {
        guard let id else { return nil }
        return streams.first(where: { $0.id == id })
    }
    
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
