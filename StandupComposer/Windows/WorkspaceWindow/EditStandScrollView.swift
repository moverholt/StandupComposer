//
//  EditStandScrollView.swift
//  StandupComposer
//
//  Created by OpenAI on 2025-12-28.
//

import SwiftUI

struct EditStandScrollView: View {
    @Binding var space: Workspace
    let stand: Standup

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                EditStandHeaderView(space: $space, stand: stand)
                ForEach(stand.entries) { entry in
                    Section {
                        if let stream = space.getStream(entry.workstreamId) {
                            EditStandEntryCard(
                                space: $space,
                                stand: stand,
                                entry: entry,
                                stream: stream
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    TabView {
        Tab("Edit", systemImage: "pencil") {
            if let stand = space.stands.last {
                EditStandScrollView(space: $space, stand: stand)
            }
        }
    }
    .frame(width: 700, height: 400)
    .environment(WorkspaceOverlayViewModel())
    .environment(UserSettings())
    .onAppear {
        let ws1Id = space.createWorkstream("Workstream 1", "WORK-1")
        let _ = space.createWorkstream("Workstream 2", "WORK-2")
        let stand1Id = space.createStandup("Standup 1")
        space.publishStandup(stand1Id)
        space.addWorkstreamEntry(ws1Id, "I completed something")
        let _ = space.createStandup("Standup 2")
    }
}
