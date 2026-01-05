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
                    ForEach(Workstream.Status.allCases) { status in
                        Text(status.description)
                            .tag(status)
                    }
                }
            }
            Section(
                header: Text("")
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
        }
    }
}

#Preview {
    @Previewable @State var stream = Workstream()
    WorkspaceWorkstreamInspectorView(stream: $stream)
}
