//
//  WorkspaceWorkstreamDetailView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceWorkstreamDetailView: View {
    @Environment(UserSettings.self) var settings
    @Binding var space: Workspace
    let stream: Workstream

    private func jiraBrowseURL(issueKey: String) -> URL? {
        let base = settings.jiraUrl.trimmingCharacters(in: .whitespaces)
        guard !base.isEmpty else { return nil }
        let path = base.hasSuffix("/") ? String(base.dropLast()) : base
        return URL(string: "\(path)/browse/\(issueKey)")
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(stream.title)
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        Button {
                            NSApp.appDelegate?.showWorkstreamPanel(stream.id)
                        } label: {
                            Image(systemName: "macwindow.on.rectangle")
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                    }
                    if stream.status != .active {
                        Text(stream.status.description)
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if let issue = stream.issueKey {
                        HStack {
                            Text(issue)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                            if let url = jiraBrowseURL(issueKey: issue) {
                                Link(destination: url) {
                                    Image(systemName: "safari")
                                        .imageScale(.medium)
                                        .padding(6)
                                        .contentShape(Rectangle())
                                }
                                .help("Open in Jira")
                            }
                        }
                    }
                }
            }
            HStack(spacing: 24) {
                VStack {
                    HStack {
                        Text("Updates")
                            .font(.title2)
                        Spacer()
                    }
                    WorkstreamUpdatesScrollView(space: $space, stream: stream)
                    WorkstreamAddUpdateInput(space: $space, stream: stream)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stream = space.streams.first {
            WorkspaceWorkstreamDetailView(space: $space, stream: stream)
        }
    }
    .environment(UserSettings.shared)
    .onAppear {
        let _ = space.createWorkstream("Preview Stream", "PREV-1")
    }
}
