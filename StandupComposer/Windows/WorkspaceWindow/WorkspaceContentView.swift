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

struct WorkspaceContentView: View {
    @Binding var streams: [Workstream]
    @Binding var stands: [Standup]
    @Binding var selected: WorkspaceSelected

    @State private var showInspector = false

    private var selectedWorkstreamIndex: Int? {
        if case let .workstream(id) = selected {
            return streams.findIndex(id: id)
        }
        return nil
    }
    
    private var selectedStandupIndex: Int? {
        if case let .standup(id) = selected {
            return stands.findIndex(id: id)
        }
        return nil
    }
    
    private var hasInspectorDetail: Bool {
        switch selected {
        case .standup, .workstream:
            return true
        case .newStandup, .newWorkstream, .none:
            return false
        }
    }
    
    var body: some View {
        NavigationSplitView {
            WorkspaceNavList(
                streams: $streams,
                stands: $stands,
                selected: $selected
            )
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 200, ideal: 280, max: 400)
        } detail: {
            if selected == .newWorkstream {
                WorkspaceNewWorkstreamView(
                    streams: $streams,
                    selected: $selected
                )
            } else if selected == .newStandup {
                WorkspaceNewStandupView(
                    streams: $streams,
                    stands: $stands,
                    selected: $selected
                )
            } else if let index = selectedWorkstreamIndex {
                WorkspaceWorkstreamDetailView(stream: $streams[index])
            } else if let index = selectedStandupIndex {
                WorkspaceStandupDetailView(
                    stand: $stands[index],
                    streams: $streams
                )
            } else {
                Text("Hello! (Nothing selected)")
            }
        }
        .frame(
            minWidth: 1000,
            minHeight: 618
        )
        .inspector(
            isPresented: $showInspector,
            content: {
                if let index = selectedWorkstreamIndex {
                    WorkspaceWorkstreamInspectorView(stream: $streams[index])
                } else if let index = selectedStandupIndex {
                    WorkspaceStandupInspectorView(stand: $stands[index])
                } else {
                    Text("Select Workstream")
                }
            }
        )
        .toolbar {
//            ToolbarItem(placement: .primaryAction) {
//                Button {
//                    selected = .newWorkstream
//                } label: {
//                    Image(systemName: "square.and.pencil")
//                }
//                .help("New Workstream")
//            }
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
    @Previewable @State var streams: [Workstream] = []
    @Previewable @State var stands: [Standup] = []
    @Previewable @State var selected = WorkspaceSelected.none
    WorkspaceContentView(
        streams: $streams,
        stands: $stands,
        selected: $selected
    )
    .onAppear {
        let ws1 = Workstream()
        let ws2 = Workstream()
        streams.append(ws1)
        streams.append(ws2)
    }
}
