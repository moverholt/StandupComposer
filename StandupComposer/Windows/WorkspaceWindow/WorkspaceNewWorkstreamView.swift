//
//  WorkspaceNewWorkstreamView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceNewWorkstreamView: View {
    @Environment(UserSettings.self) var settings
    @Binding var workspace: Workspace
    @State private var title = "New Workstream"
    
    private func handleSubmit() {
        if title.isEmpty {
            return
        }
        var stream = Workstream()
        stream.title = title
        workspace.streams.append(stream)
        settings.workspaceSelected = .workstream(stream.id)
    }
    
    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .font(.title)
                .onSubmit {
                    handleSubmit()
                }
            Spacer()
            Button(
                action: {
                    handleSubmit()
                }
            ) {
                Label("Create Workstream", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    @Previewable @State var workspace = Workspace()
    WorkspaceNewWorkstreamView(workspace: $workspace)
}
