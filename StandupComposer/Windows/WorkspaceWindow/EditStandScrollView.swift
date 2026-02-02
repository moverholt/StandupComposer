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
    
    @State private var showWorkstreamPicker = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                HStack {
                    if let prev = space.getStand(stand.previousStandupId) {
                        Text("Previous standup: \(prev.title)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("This is the first standup")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        showWorkstreamPicker = true
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.borderless)
                    .popover(
                        isPresented: $showWorkstreamPicker,
                        arrowEdge: .top
                    ) {
                        WorkstreamPickerPopover(space: $space, stand: stand)
                            .frame(minWidth: 220, minHeight: 200)
                    }
                }
                .padding(.bottom, 8)
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
