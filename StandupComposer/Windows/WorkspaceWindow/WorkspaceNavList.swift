//
//  WorkspaceNavList.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceNavList: View {
    @Environment(UserSettings.self) var settings
    @Binding var workspace: Workspace
    @State private var expandPaused = false
    @State private var expandComplete = false

    var body: some View {
        @Bindable var settings = settings
        List(selection: $settings.workspaceSelected) {
            Section("Active Workstreams") {
                ForEach(
                    workspace.streams.active.sorted { $0.updated > $1.updated }
                ) { ws in
                    Text(ws.description)
                        .tag(WorkspaceSelected.workstream(ws.id))
                }
                Label("New Workstream", systemImage: "water.waves")
                    .tag(WorkspaceSelected.newWorkstream)
            }
            .listSectionSeparator(.visible)
            Section("Standups") {
                if !workspace.isEditingStandup {
                    Label("New Standup", systemImage: "square.and.pencil")
                        .tag(WorkspaceSelected.newStandup)
                        .disabled(true)
                }
                ForEach(
                    workspace.stands.sorted { $0.updated > $1.updated }
                ) { st in
                    Label(
                        st.title,
                        systemImage: st.editing ? "pencil" : "lock"
                    )
                    .tag(WorkspaceSelected.standup(st.id))
                }
            }
            .listSectionSeparator(.visible)
            Section("Paused Workstreams", isExpanded: $expandPaused) {
                ForEach(workspace.streams.paused) { model in
                    Text(model.title)
                        .tag(WorkspaceSelected.workstream(model.id))
                }
            }
            Section("Completed Workstreams", isExpanded: $expandComplete) {
                ForEach(workspace.streams.completed) { model in
                    Text(model.title)
                        .tag(WorkspaceSelected.workstream(model.id))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var workspace = Workspace()
    WorkspaceNavList(workspace: $workspace)
        .listStyle(.sidebar)
        .environment(UserSettings())
        .onAppear {
            var ws1 = Workstream()
            ws1.title = "Some work to be done"
            ws1.issueKey = "FOOD-1234"
            workspace.streams.append(ws1)
            var ws2 = Workstream()
            ws2.title = "Some work to be done"
            ws2.issueKey = "PASTA-1234"
            workspace.streams.append(ws2)
            
            var s1 = Standup(.yesterday)
            s1.title = "1/1/2026 Standup"
            s1.publish()
            workspace.stands.append(s1)
            
            var s2 = Standup(.today)
            s2.title = "1/2/2026 Standup"
            workspace.stands.append(s2)
        }
}
