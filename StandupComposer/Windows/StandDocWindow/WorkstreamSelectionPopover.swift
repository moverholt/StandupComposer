//
//  WorkstreamSelectionPopover.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/24/26.
//

import SwiftUI

struct WorkstreamSelectionPopover: View {
    @Binding var space: Workspace
    @Binding var stand: Standup
//    let section: Standup.Section
    
    var body: some View {
        ScrollView {
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Active Workstreams")
//                    .font(.headline)
//                    .padding(.bottom, 4)
//                
//                ForEach(
//                    space.streams.active.sorted { $0.updated > $1.updated }
//                ) { workstream in
//                    HStack {
//                        Toggle(
//                            "",
//                            isOn: Binding(
//                                get: {
//                                    stand.hasWorkstream(workstream.id, in: section)
//                                },
//                                set: { isOn in
//                                    if isOn {
//                                        stand.addWorkstream(workstream, to: section)
//                                    } else {
//                                        stand.removeWorkstream(workstream.id, from: section)
//                                    }
//                                }
//                            )
//                        )
//                        .toggleStyle(.checkbox)
//                        .labelsHidden()
//                        
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text(workstream.title)
//                                .font(.body)
//                            if let issueKey = workstream.issueKey {
//                                Text(issueKey)
//                                    .font(.caption)
//                                    .foregroundStyle(.secondary)
//                            }
//                        }
//                        
//                        Spacer()
//                    }
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                }
//            }
//            .padding()
        }
        .frame(width: 300, height: 400)
    }
}

//#Preview {
//    @Previewable @State var space = Workspace()
//    @Previewable @State var stand = Standup(space.id)
//    
//    WorkstreamSelectionPopover(
//        space: $space,
//        stand: $stand,
//        section: .today
//    )
//    .onAppear {
//        var ws1 = Workstream()
//        ws1.title = "Sample Workstream 1"
//        ws1.issueKey = "TEST-123"
//        
//        var ws2 = Workstream()
//        ws2.title = "Sample Workstream 2"
//        ws2.issueKey = "TEST-456"
//        
//        var ws3 = Workstream()
//        ws3.title = "Sample Workstream 3"
//        
//        space.streams = [ws1, ws2, ws3]
//    }
//}
