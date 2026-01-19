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
    @Binding var workspace: Workspace
    @Environment(UserSettings.self) var settings

    @State private var ovm = WorkspaceOverlayViewModel()
    
    private var selected: WorkspaceSelected {
        settings.workspaceSelected
    }

    private var selectedWorkstreamIndex: Int? {
        if case let .workstream(id) = selected {
            return workspace.streams.findIndex(id: id)
        }
        return nil
    }
    
    private var selectedStandupIndex: Int? {
        if case let .standup(id) = selected {
            return workspace.stands.findIndex(id: id)
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
        if let id = ovm.workstreamAddUpdateId {
            workspace.addWorkstreamUpdate(
                id: id,
                body: ovm.text,
                standId: ovm.workstreamAddUpdateStandId
            )
        } else if let id = ovm.workstreamAddPlanId {
            workspace.addWorkstreamPlan(
                id: id,
                body: ovm.text,
                standId: ovm.workstreamAddPlanStandId
            )
        }
        ovm.close()
    }
    
    var body: some View {
        @Bindable var settings = settings
        NavigationSplitView(
            columnVisibility: $settings.workspaceColumnVisibility
        ) {
            WorkspaceNavList(workspace: $workspace)
                .listStyle(.sidebar)
                .navigationSplitViewColumnWidth(
                    min: 200,
                    ideal: 280,
                    max: 400
                )
        } detail: {
            VStack(spacing: 0) {
                if selected == .newWorkstream {
                    WorkspaceNewWorkstreamView(workspace: $workspace)
                } else if selected == .newStandup {
                    WorkspaceNewStandupView(workspace: $workspace)
                } else if let index = selectedWorkstreamIndex {
                    WorkspaceWorkstreamDetailView(
                        space: workspace,
                        stream: $workspace.streams[index]
                    )
                } else if let index = selectedStandupIndex {
                    WorkspaceStandupDetailView(
                        stand: $workspace.stands[index],
                        workspace: $workspace
                    )
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
                if let index = selectedWorkstreamIndex {
                    WorkspaceWorkstreamInspectorView(
                        stream: $workspace.streams[index],
                        space: $workspace
                    )
                } else if let index = selectedStandupIndex {
                    WorkspaceStandupInspectorView(
                        stand: $workspace.stands[index],
                        space: $workspace
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
    @Previewable @State var workspace = Workspace()
    @Previewable @State var settings = UserSettings()
    WorkspaceContentView(workspace: $workspace)
        .environment(settings)
        .onAppear {
            let ws1 = Workstream()
            let ws2 = Workstream()
            workspace.streams.append(ws1)
            workspace.streams.append(ws2)
            let stand = Standup(.today, title: "Today")
            workspace.stands.append(stand)
            settings.workspaceSelected = .standup(stand.id)
        }
}

