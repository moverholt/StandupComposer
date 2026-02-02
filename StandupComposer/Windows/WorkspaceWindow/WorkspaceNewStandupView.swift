//
//  WorkspaceNewStandupView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/3/26.
//

import SwiftUI

struct WorkspaceNewStandupView: View {
    @Environment(UserSettings.self) var settings
    @Environment(WorkspaceOverlayViewModel.self) private var ovm
    @Binding var space: Workspace
    
    @State private var title: String = "New Standup"
    
    @MainActor
    private func handleSubmit() {
        let id = space.createStandup(title)
        settings.workspaceSelected = .standup(id)
    }
    
    private var createDisabled: Bool {
        title.isEmpty || space.streams.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("New Standup")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Create Standup") {
                    handleSubmit()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            Divider()
            Form {
                Section(
                    header: Text("New Standup")
                ) {
                    TextField("Title", text: $title)
                }
                if space.streams.isEmpty {
                    Text("No Active Workstreams")
                        .foregroundStyle(.primary)
                        .italic()
                } else {
                    Section {
                        Text("-24")
                            .font(.largeTitle)
                        ForEach(space.streams.active) { stream in
                            StreamHeaderView(stream: stream)
                            if let i = space.streams.findIndex(id: stream.id) {
//                                Prev24StreamView(stream: $pace.streams[i])
//                                    .padding(.bottom)
                            }
                        }
                    }
                    Section {
                        Text("+24")
                            .font(.largeTitle)
                        ForEach(space.streams.active) { stream in
                            StreamHeaderView(stream: stream)
                            if let i = space.streams.findIndex(id: stream.id) {
//                                Next24StreamView(stream: $pace.streams[i])
//                                    .padding(.bottom)
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onSubmit {
            handleSubmit()
        }
        .onAppear {
            title = "\(IsoDay.today.formatted(style: .complete))"
        }
    }
}

extension WorkspaceNewStandupView {
    
    struct StreamHeaderView: View {
        let stream: Workstream
        
        var body: some View {
            VStack {
                HStack(alignment: .top) {
                    Text(stream.title)
                        .font(.title)
                    Spacer()
                    if let key = stream.issueKey {
                        Text("[\(key)]")
                            .font(.footnote)
                            .fontDesign(.monospaced)
                            .foregroundColor(.secondary)
                    }
                }
            }

        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    WorkspaceNewStandupView(space: $space)
        .environment(UserSettings())
        .environment(WorkspaceOverlayViewModel())
        .frame(width: 400, height: 600)
        .onAppear {
            var ws1 = Workstream(space.id)
            ws1.title = "Add new cheeses to the cheese menu"
            ws1.issueKey = "FOOD-10"
        }
}

