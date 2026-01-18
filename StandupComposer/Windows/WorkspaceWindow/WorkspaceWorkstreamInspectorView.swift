//
//  WorkspaceWorkstreamInspectorView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceWorkstreamInspectorView: View {
    @Environment(UserSettings.self) var settings
    @Binding var stream: Workstream
    @Binding var space: Workspace
    
    @State private var showConfirm = false
    
    var body: some View {
        Form {
            Section(
                header: Text("Info")
            ) {
                TextField("Title", text: $stream.title)
                TextField(
                    "Jira Issue Key",
                    text: Binding(
                        get: {
                            stream.issueKey ?? ""
                        },
                        set: {
                            if $0.isEmpty {
                                stream.issueKey = nil
                            } else {
                                stream.issueKey = $0
                            }
                        }
                    )
                )
                Picker("Status", selection: $stream.status) {
                    ForEach(Workstream.Status.allCases, id: \.self) { status in
                        Text(status.description)
                            .tag(status)
                    }
                }
            }
            Section(
                header: Text("Meta")
            ) {
                HStack {
                    Text("ID")
                    Spacer()
                    Text(stream.id.uuidString)
                }
                HStack {
                    Text("Created")
                    Spacer()
                    Text(stream.created.formatted())
                }
                HStack {
                    Text("Updated")
                    Spacer()
                    Text(stream.updated.formatted())
                }
            }
            Button(role: .destructive) {
                showConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .confirmationDialog(
                "Are you sure you want to delete this?",
                isPresented: $showConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    space.deleteWorkstream(stream.id)
                    settings.workspaceSelected = .none
                }
                Button("Cancel", role: .cancel) {
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var stream = Workstream()
    @Previewable @State var space = Workspace()
    WorkspaceWorkstreamInspectorView(stream: $stream, space: $space)
        .environment(UserSettings())
}
