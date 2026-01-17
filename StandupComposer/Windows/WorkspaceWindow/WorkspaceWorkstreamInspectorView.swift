//
//  WorkspaceWorkstreamInspectorView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceWorkstreamInspectorView: View {
    @Binding var stream: Workstream
    
    var body: some View {
        Form {
            Section(
                header: Text("Info")
            ) {
                TextField("Title", text: $stream.title)
                TextField(
                    "Jira Issue Key",
                    text: Binding(
                        get: {
                            stream.issueKey ?? ""
                        },
                        set: {
                            if $0.isEmpty {
                                stream.issueKey = nil
                            } else {
                                stream.issueKey = $0
                            }
                        }
                    )
                )
                Picker("Status", selection: $stream.status) {
                    ForEach(Workstream.Status.allCases, id: \.self) { status in
                        Text(status.description)
                            .tag(status)
                    }
                }
            }
            Section(
                header: Text("Meta")
            ) {
                HStack {
                    Text("ID")
                    Spacer()
                    Text(stream.id.uuidString)
                }
                HStack {
                    Text("Created")
                    Spacer()
                    Text(stream.created.formatted())
                }
                HStack {
                    Text("Updated")
                    Spacer()
                    Text(stream.updated.formatted())
                }
            }
            Section("Status") {
                Toggle("Deleted", isOn: $stream.deleted)
            }
        }
    }
}

#Preview {
    @Previewable @State var stream = Workstream()
    WorkspaceWorkstreamInspectorView(stream: $stream)
}
