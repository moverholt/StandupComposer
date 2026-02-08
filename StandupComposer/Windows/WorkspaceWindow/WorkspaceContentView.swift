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
    @Environment(WorkspaceOverlayViewModel.self) var ovm

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
    
    var body: some View {
        @Bindable var settings = settings
        NavigationSplitView(
            columnVisibility: $settings.workspaceColumnVisibility
        ) {
            WorkspaceNavList(space: $space)
                .listStyle(.sidebar)
                .navigationSplitViewColumnWidth(
                    min: 200,
                    ideal: 280,
                    max: 600
                )
        } detail: {
            VStack(spacing: 0) {
                if selected == .newWorkstream {
                    WorkspaceNewWorkstreamView(space: $space)
                } else if selected == .newStandup {
                    WorkspaceNewStandupView(space: $space)
                } else if let stream = selectedWorkstream { WorkspaceWorkstreamDetailView(space: $space, stream: stream)
                } else if let stand = selectedStandup {
                    WorkspaceStandupDetailView(space: $space, stand: stand)
                } else {
                    Text("Hello! (Nothing selected)")
                }
            }
            .padding()
            .overlay(alignment: .bottom) {
                Group {
                    if ovm.showOverlay {
                        WorkspaceQuickInputOverlay(space: $space)
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
        .environment(WorkspaceOverlayViewModel())
        .onAppear {
            let ws1Id = space.createWorkstream("Workstream 1", "PREV-1")
            settings.workspaceColumnVisibility = .detailOnly
            let sId = space.createStandup("Preview Standup")
            settings.workspaceSelected = .standup(sId)
        }
}

