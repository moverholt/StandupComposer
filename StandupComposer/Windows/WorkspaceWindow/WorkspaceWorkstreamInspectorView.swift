//
//  WorkspaceWorkstreamInspectorView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceWorkstreamInspectorView: View {
    @Environment(UserSettings.self) var settings
    @Binding var space: Workspace
    let stream: Workstream

    @State private var showConfirm = false
    
    private var issueKeyBinding: Binding<String> {
        Binding(
            get: { stream.issueKey ?? "" },
            set: {
                var newStream = stream
                newStream.issueKey = $0.isEmpty ? nil : $0
                space.updateWorkstream(newStream)
            }
        )
    }
    
    private var streamBinding: Binding<Workstream> {
        Binding(
            get: { stream },
            set: { space.updateWorkstream($0) }
        )
    }
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: streamBinding.title)
                TextField(
                    "Jira Issue Key",
                    text: issueKeyBinding,
                    prompt: Text("e.g. PROJ-123")
                )
                Picker("Status", selection: streamBinding.status) {
                    ForEach(Workstream.Status.allCases, id: \.self) { status in
                        Text(status.description.capitalized).tag(status)
                    }
                }
                .pickerStyle(.menu)
            }
            Section("About") {
                LabeledContent("ID") {
                    Text(stream.id.uuidString)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
                .help(stream.id.uuidString)
                LabeledContent("Created", value: stream.created.formatted())
                LabeledContent("Updated", value: stream.updated.formatted())
            }
            Section {
                Button(role: .destructive) {
                    showConfirm = true
                } label: {
                    Label("Delete Workstream", systemImage: "trash")
                }
                .buttonStyle(.borderless)
            }
            .confirmationDialog("Delete Workstream?", isPresented: $showConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    space.deleteWorkstream(stream.id)
                    settings.workspaceSelected = .none
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stream = space.streams.first {
            WorkspaceWorkstreamInspectorView(space: $space, stream: stream)
        }
    }
    .onAppear {
        var s1 = space.createWorkstream("Stream 1", "S1-1")
    }
    .environment(UserSettings())
    .padding()
    .frame(width: 300)
}
