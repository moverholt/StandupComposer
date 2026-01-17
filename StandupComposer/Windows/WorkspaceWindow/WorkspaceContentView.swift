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
}

@Observable
class WorkspaceOverlayViewModel {
    var showOverlay = false
    var text: String = ""
    
    var workstreamAddUpdateId: Workstream.ID?
    var workstreamAddUpdateStandId: Standup.ID?
    
    func close() {
        workstreamAddUpdateId = nil
        workstreamAddUpdateStandId = nil
        showOverlay = false
        text = ""
    }
    
    func showWorkstreamAddUpdate(
        _ id: Workstream.ID,
        standId: Standup.ID?
    ) {
        if workstreamAddUpdateId == id {
            close()
            return
        }
        workstreamAddUpdateId = id
        workstreamAddUpdateStandId = standId
        if !showOverlay {
            showOverlay = true
        }
    }
}

struct WorkspaceContentView: View {
    @Binding var workspace: Workspace
    @Environment(UserSettings.self) var settings

    @State private var ovm = WorkspaceOverlayViewModel()
    @State private var showInspector = false
    @FocusState private var quickInputFocused: Bool
    
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
                        VStack(spacing: 8) {
                            if let id = ovm.workstreamAddUpdateId {
                                Text(id.uuidString)
                            }
                            TextField("Quick input…", text: $ovm.text)
                                .textFieldStyle(.roundedBorder)
                                .frame(minWidth: 280)
                                .focused($quickInputFocused)
                                .onSubmit {
                                    submitOverlay()
                                }
                            HStack {
                                Button("Cancel") {
                                    ovm.close()
                                }
                                Spacer()
                                Button("Add") {
                                    submitOverlay()
                                }
                                .keyboardShortcut(.defaultAction)
                                .disabled(
                                    ovm.text.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    ).isEmpty
                                )
                            }
                        }
                        .padding(12)
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                        )
                        .shadow(radius: 12)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.default, value: ovm.showOverlay)
            }
            .onChange(of: ovm.showOverlay) { isShown in
                quickInputFocused = isShown
            }
        }
        .inspector(
            isPresented: $showInspector,
            content: {
                if let index = selectedWorkstreamIndex {
                    WorkspaceWorkstreamInspectorView(
                        stream: $workspace.streams[index]
                    )
                } else if let index = selectedStandupIndex {
                    WorkspaceStandupInspectorView(
                        stand: $workspace.stands[index]
                    )
                } else {
                    Text("Select Workstream")
                }
            }
        )
        .environment(ovm)
        .toolbar {
            if hasInspectorDetail {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showInspector.toggle()
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

