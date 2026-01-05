//
//  WorkspaceNavList.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceNavList: View {
    @Binding var streams: [Workstream]
    @Binding var stands: [Standup]
    @Binding var selected: WorkspaceSelected
    
    @State private var expandPaused = false
    @State private var expandComplete = false

    var body: some View {
        List(selection: $selected) {
            Section("Active Workstreams") {
                ForEach(
                    streams.active.sorted { $0.updated > $1.updated }
                ) { ws in
                    Text(ws.description)
                        .tag(WorkspaceSelected.workstream(ws.id))
                }
            }
            .listSectionSeparator(.visible)
            Section("Create") {
                Label("New Standup", systemImage: "square.and.pencil")
                    .tag(WorkspaceSelected.newStandup)
                Label("New Workstream", systemImage: "water.waves")
                    .tag(WorkspaceSelected.newWorkstream)
            }
            .listSectionSeparator(.visible)
            Section("Standups") {
                ForEach(
                    stands.available.sorted { $0.updated > $1.updated }
                ) { st in
                    Text(st.title)
                        .tag(WorkspaceSelected.standup(st.id))
                }
            }
            .listSectionSeparator(.visible)
            Section("Paused Workstreams", isExpanded: $expandPaused) {
                ForEach(streams.paused) { model in
                    Text(model.title)
                        .tag(WorkspaceSelected.workstream(model.id))
                }
            }
            Section("Completed Workstreams", isExpanded: $expandComplete) {
                ForEach(streams.completed) { model in
                    Text(model.title)
                        .tag(WorkspaceSelected.workstream(model.id))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var streams: [Workstream] = []
    @Previewable @State var stands: [Standup] = []
    @Previewable @State var selected: WorkspaceSelected = .none
    WorkspaceNavList(
        streams: $streams,
        stands: $stands,
        selected: $selected
    )
    .listStyle(.sidebar)
    .onAppear {
        var ws1 = Workstream()
        ws1.title = "Some work to be done"
        ws1.issueKey = "FOOD-1234"
        streams.append(ws1)
        var ws2 = Workstream()
        ws2.title = "Some work to be done"
        ws2.issueKey = "PASTA-1234"
        streams.append(ws2)
    }
}
