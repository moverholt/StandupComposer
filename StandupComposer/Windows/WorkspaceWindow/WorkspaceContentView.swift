//
//  WorkspaceContentView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

enum WorkspaceSelected: Codable, Hashable {
    case newWorkstream
    case workstream(Workstream.ID)
    case newStandup
    case standup(Standup.ID)
    case none
    
    var hasInspector: Bool {
        switch self {
        case .newWorkstream:
            false
        case .workstream(_):
            true
        case .newStandup:
            false
        case .standup(_):
            true
        case .none:
            false
        }
    }
}

struct WorkspaceContentView: View {
    @Binding var space: Workspace
    @Environment(UserSettings.self) var settings

    @State private var ovm = WorkspaceOverlayViewModel()
    
    private var selected: WorkspaceSelected {
        settings.workspaceSelected
    }

    private var selectedWorkstream: Workstream? {
        if case let .workstream(id) = selected {
            return space.streams.find(id: id)
        }
        return nil
    }
    
    private var selectedStandup: Standup? {
        if case let .standup(id) = selected {
            return space.stands.find(id: id)
        }
        return nil
    }
    
    private var hasInspectorDetail: Bool {
        switch settings.workspaceSelected {
        case .standup, .workstream:
            return true
        case .newStandup, .newWorkstream, .none:
            return false
        }
    }
    
    private func submitOverlay() {
        let trimmed = ovm.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let standId = ovm.draftNotesStandId, let entryId = ovm.draftNotesPlus24EntryId {
            var sp = space
            guard var st = sp.getStand(standId),
                  let idx = st.entries.firstIndex(where: { $0.id == entryId })
            else {
                ovm.close()
                return
            }
            st.entries[idx].plus24DraftNotes = trimmed.isEmpty ? nil : trimmed
            sp.updateStandup(st)
            space = sp
        } else if let standId = ovm.draftNotesStandId, let entryId = ovm.draftNotesEntryId {
            var sp = space
            guard var st = sp.getStand(standId),
                  let idx = st.entries.firstIndex(where: { $0.id == entryId })
            else {
                ovm.close()
                return
            }
            st.entries[idx].minus24DraftNotes = trimmed.isEmpty ? nil : trimmed
            sp.updateStandup(st)
            space = sp
        } else if !trimmed.isEmpty, let id = ovm.workstreamAddUpdateId {
            space.addWorkstreamEntry(id, trimmed)
        }
        ovm.close()
    }
    
    var body: some View {
        @Bindable var settings = settings
        NavigationSplitView(
            columnVisibility: $settings.workspaceColumnVisibility
        ) {
            WorkspaceNavList(workspace: $space)
                .listStyle(.sidebar)
                .navigationSplitViewColumnWidth(
                    min: 200,
                    ideal: 280,
                    max: 400
                )
        } detail: {
            VStack(spacing: 0) {
                if selected == .newWorkstream {
                    WorkspaceNewWorkstreamView(space: $space)
                } else if selected == .newStandup {
                    WorkspaceNewStandupView(space: $space)
                } else if let stream = selectedWorkstream {
                    WorkspaceWorkstreamDetailView(
                        space: $space,
                        stream: stream
                    )
                } else if let stand = selectedStandup {
                    WorkspaceStandupDetailView(space: $space, stand: stand)
                } else {
                    Text("Hello! (Nothing selected)")
                }
            }
            .padding()
            .overlay(alignment: .bottomTrailing) {
                Group {
                    if ovm.showOverlay {
                        WorkspaceQuickInputOverlay(
                            onSubmit: {
                                submitOverlay()
                            }
                        )
                    }
                }
                .animation(.default, value: ovm.showOverlay)
            }
        }
        .inspector(
            isPresented: $settings.workspaceShowInspector,
            content: {
                if let stream = selectedWorkstream {
                    WorkspaceWorkstreamInspectorView(
                        space: $space,
                        stream: stream
                    )
                } else if let stand = selectedStandup {
                    WorkspaceStandupInspectorView(
                        space: $space,
                        stand: stand
                    )
                } else {
                    EmptyView()
                }
            }
        )
        .environment(ovm)
        .toolbar {
            if hasInspectorDetail {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        settings.workspaceShowInspector.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .help("Toggle Inspector")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    @Previewable @State var settings = UserSettings()
    WorkspaceContentView(space: $space)
        .environment(settings)
        .onAppear {
            let wsId1 = space.createWorkstream("Workstream 1", "PREV-1")
            let wsId2 = space.createWorkstream("Workstream 2", "PREV-2")
        }
}

