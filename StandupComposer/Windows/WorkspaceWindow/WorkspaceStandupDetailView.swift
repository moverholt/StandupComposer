//
//  WorkspaceStandupDetailView.swift
//  StandupComposer
//
//  Created by Assistant on 12/27/25.
//

import SwiftUI

struct WorkspaceStandupDetailView: View {
    @Environment(UserSettings.self) var settings
    
    @Binding var space: Workspace
    let stand: Standup

    private func publish() {
        space.publishStandup(stand.id)
    }

    private var formattedDate: String {
        stand.rangeStart.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: stand.published ? "doc.text.fill" : "doc.text")
                    .font(.title2)
                    .foregroundColor(stand.published ? .secondary : .accentColor)
                    .frame(width: 28, alignment: .center)

                VStack(alignment: .leading, spacing: 2) {
                    Text(stand.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textSelection(.enabled)
                    HStack(spacing: 6) {
                        Text(formattedDate)
                        Text("·")
                        Text(stand.editing ? "Draft" : "Published")
                            .foregroundStyle(stand.editing ? .orange : .green)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                if stand.editing {
                    Button(action: publish) {
                        Label("Publish", systemImage: "checkmark.seal.fill")
                    }
                    .controlSize(.regular)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.bottom, 12)
            if stand.editing {
                TabView {
                    Tab("Edit", systemImage: "pencil") {
                        EditStandScrollView(space: $space, stand: stand)
                    }
                    Tab(
                        "Formatted",
                        systemImage: "paragraphsign"
                    ) {
                        StandFormattedView(stand: stand, space: $space)
                    }
                }
                .tabViewStyle(.grouped)
            } else {
                StandFormattedView(stand: stand, space: $space)
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stand = space.stands.first {
            WorkspaceStandupDetailView(space: $space, stand: stand)
        }
    }
    .frame(width: 700, height: 400)
    .environment(UserSettings())
    .environment(WorkspaceOverlayViewModel())
    .onAppear {
        let _ = space.createWorkstream("Workstream 1", "PREV-1")
        let _ = space.createWorkstream("Workstream 2", "PREV-2")
        let _ = space.createStandup("Preview Standup")
    }
}

