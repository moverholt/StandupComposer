//
//  WorkspaceNewStandupView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/3/26.
//

import SwiftUI

struct WorkspaceNewStandupView: View {
    @Binding var workspace: Workspace
    @State private var title: String = "New Standup"
    @Environment(UserSettings.self) var settings
    
    private func handleSubmit() {
        let stand = workspace.createStandup(title)
        settings.workspaceSelected = .standup(stand.id)
    }
    
    private var createDisabled: Bool {
        title.isEmpty || workspace.streams.isEmpty
    }
    
    var body: some View {
        Form {
            Section(
                header: Text("New Standup")
            ) {
                TextField("Title", text: $title)
                if let prev = workspace.previousStandup {
                    HStack {
                        Text("Last Standup")
                        Spacer()
                        Text(prev.title)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section(
                header: Text(
                    "Active workstreams to be included in this standup"
                )
            ) {
                if workspace.streams.isEmpty {
                    Text("No Active Workstreams")
                        .foregroundStyle(.primary)
                        .italic()
                } else {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(workspace.streams.active) { stream in
                            VStack {
                                HStack {
                                    if let key = stream.issueKey {
                                        Text("[\(key)]")
                                            .font(.footnote)
                                            .fontDesign(.monospaced)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(stream.title)
                                        .font(.title)
                                }
                            }
                            let updates = stream.updates.noStandup
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Updates since previous standup")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                if updates.isEmpty {
                                    Text("None")
                                } else {
                                    ForEach(updates) { upd in
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .font(.footnote)
                                            Text(upd.body)
                                                .font(.title3)
                                        }
                                    }
                                }
                            }
//                            let completed = stream.plans.completedSince(
//                                workspace.previousStandup
//                            )
//                            VStack(alignment: .leading, spacing: 12) {
//                                Text("Plans completed since last standup")
//                                    .font(.headline)
//                                    .foregroundStyle(.secondary)
//                                if completed.isEmpty {
//                                    Text("None")
//                                } else {
//                                    ForEach(completed) { pln in
//                                        HStack {
//                                            Image(systemName: "circle.fill")
//                                                .font(.footnote)
//                                            Text(pln.body)
//                                                .font(.title3)
//                                        }
//                                    }
//                                }
//                            }
                        }
                    }
                }
            }
            Button("Create", action: handleSubmit)
                .disabled(createDisabled)
                .buttonStyle(.borderedProminent)
        }
        .formStyle(.grouped)
        .onSubmit {
            handleSubmit()
        }
        .onAppear {
            title = "\(IsoDay.today.formatted(style: .complete)) - Standup"
        }
    }
}

#Preview {
    @Previewable @State var workspace = Workspace()
    WorkspaceNewStandupView(workspace: $workspace)
        .environment(UserSettings())
        .onAppear {
            var ws1 = Workstream()
            ws1.title = "Add new cheeses to the cheese menu"
            ws1.issueKey = "FOOD-10"
            var ws2 = Workstream()
            ws2.title = "Add new sausages to the sausage menu"
            ws2.issueKey = "FOOD-20"
            var ws3 = Workstream()
            ws3.title = "Add new pizza to the pizza menu"
            ws3.issueKey = "FOOD-30"
            
            ws1.appendUpdate(.today, body: "Met with product manager")
            
            workspace.streams.append(ws1)
            workspace.streams.append(ws2)
            workspace.streams.append(ws3)
        }
}
