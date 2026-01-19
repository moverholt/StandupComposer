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
    
    private var issueKeyBinding: Binding<String> {
        Binding(
            get: { stream.issueKey ?? "" },
            set: { stream.issueKey = $0.isEmpty ? nil : $0 }
        )
    }

    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: $stream.title)
                TextField("Jira Issue Key", text: issueKeyBinding, prompt: Text("e.g. PROJ-123"))
                Picker("Status", selection: $stream.status) {
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
    @Previewable @State var stream = Workstream()
    @Previewable @State var space = Workspace()
    WorkspaceWorkstreamInspectorView(stream: $stream, space: $space)
        .environment(UserSettings())
        .padding()
        .frame(width: 300)
}
