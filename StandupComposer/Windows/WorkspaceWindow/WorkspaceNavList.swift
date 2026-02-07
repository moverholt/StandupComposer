//
//  WorkspaceNavList.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceNavList: View {
    @Environment(UserSettings.self) var settings
    @Binding var space: Workspace
    @State private var expandPaused = false
    @State private var expandComplete = false
    @State private var expandPrevious = false

    private var thisMonday: IsoDay { IsoDay.today.thisWeekMonday }
    private var currentWeekSunday: IsoDay { thisMonday.addDays(6) }
    private var currentWeekStands: [Standup] {
        space.stands
            .filter { $0.day >= thisMonday && $0.day <= currentWeekSunday && $0.published && $0.id != space.editingStandup?.id }
            .sorted { $0.day > $1.day }
    }
    private var previousStands: [Standup] {
        space.stands
            .filter { $0.day < thisMonday && $0.published }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        @Bindable var settings = settings
        List(selection: $settings.workspaceSelected) {
            Section("Active Workstreams") {
                ForEach(
                    space.streams.active.sorted { $0.updated > $1.updated }
                ) { ws in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ws.title)
                        if let key = ws.issueKey {
                            Text(key)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tag(WorkspaceSelected.workstream(ws.id))
                }
                Label("New Workstream", systemImage: "water.waves")
                    .tag(WorkspaceSelected.newWorkstream)
            }
            .listSectionSeparator(.visible)
            Section("Current Standup") {
                if let st = space.editingStandup {
                    Label(st.title, systemImage: "pencil")
                    .tag(WorkspaceSelected.standup(st.id))
                } else {
                    Label("New Standup", systemImage: "square.and.pencil")
                        .tag(WorkspaceSelected.newStandup)
                }
            }
            Section("This Week") {
                if currentWeekStands.isEmpty {
                    Text("None")
                } else {
                    ForEach(currentWeekStands) { st in
                        Label(st.title, systemImage: st.editing ? "pencil" : "checkmark.circle")
                            .tag(WorkspaceSelected.standup(st.id))
                    }
                }
            }
            Section("Previous Standups", isExpanded: $expandPrevious) {
                if previousStands.isEmpty {
                    Text("None")
                } else {
                    ForEach(previousStands) { st in
                        Label(st.title, systemImage: st.editing ? "pencil" : "checkmark.circle")
                            .tag(WorkspaceSelected.standup(st.id))
                    }
                }
            }
            .listSectionSeparator(.visible)
            Section("Paused Workstreams", isExpanded: $expandPaused) {
                if space.streams.paused.isEmpty {
                    Text("None")
                } else {
                    ForEach(space.streams.paused) { model in
                        Text(model.title)
                            .tag(WorkspaceSelected.workstream(model.id))
                    }
                }
            }
            Section("Completed Workstreams", isExpanded: $expandComplete) {
                if space.streams.completed.isEmpty {
                    Text("None")
                } else {
                    ForEach(space.streams.completed) { model in
                        Text(model.title)
                            .tag(WorkspaceSelected.workstream(model.id))
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    WorkspaceNavList(space: $space)
        .listStyle(.sidebar)
        .environment(UserSettings())
        .frame(width: 400, height: 700)
        .onAppear {
            let ws1Id = space.createWorkstream("Workstream 1", "FOOD-1234")
            let ws2Id = space.createWorkstream("Workstream 2", "FOOD-5789")
            let thisMonday = IsoDay.today.thisWeekMonday
            let lastWeekMonday = thisMonday.subDays(7)
            let olderMonday = thisMonday.subDays(14)
            let s1Id = space.createStandup("Standup 1", start: thisMonday.start)
            let s2Id = space.createStandup("Standup 2", start: thisMonday.addDays(1).start)
            let s3Id = space.createStandup("Standup 3", start: IsoDay.today.start)
            space.publishStandup(s1Id)
            space.publishStandup(s2Id)
            space.publishStandup(s3Id)
            let s4Id = space.createStandup("Standup 4", start: lastWeekMonday.start)
            let s5Id = space.createStandup("Standup 5", start: lastWeekMonday.addDays(3).start)
            space.publishStandup(s4Id)
            space.publishStandup(s5Id)
            let s6Id = space.createStandup("Standup 6", start: olderMonday.start)
            let s7Id = space.createStandup("Standup 7", start: olderMonday.addDays(1).start)
            let s8Id = space.createStandup("Standup 8", start: thisMonday.addDays(2).start)
            space.publishStandup(s6Id)
            space.publishStandup(s7Id)
            space.publishStandup(s8Id)
            let s9Id = space.createStandup("Standup 9", start: lastWeekMonday.addDays(5).start)
            space.publishStandup(s9Id)
        }
}
