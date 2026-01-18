//
//  EditStandScrollView.swift
//  StandupComposer
//
//  Created by OpenAI on 2025-12-28.
//

import SwiftUI

struct EditStandScrollView: View {
    @Binding var stand: Standup
    @Binding var workspace: Workspace
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("-24")
                            .font(.largeTitle)
                            .fontDesign(.monospaced)
                        Spacer()
                    }
                    Divider()
                        .padding(.bottom)
                    VStack(alignment: .leading, spacing: 36) {
                        ForEach(stand.prevDay) { upd in
                            if let ws = workspace.streams.find(id: upd.ws.id) {
                                WSUpdateRowView(stream: ws, stand: $stand)
                            }
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("+24")
                            .font(.largeTitle)
                            .fontDesign(.monospaced)
                        Spacer()
                    }
                    Divider()
                        .padding(.bottom)
                    VStack(alignment: .leading, spacing: 36) {
                        ForEach(stand.today) { upd in
                            if let ws = workspace.streams.find(id: upd.ws.id) {
                                WSPlanRowView(stream: ws, stand: $stand)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(.today)
    @Previewable @State var workspace = Workspace()
    EditStandScrollView(stand: $stand, workspace: $workspace)
        .padding()
        .frame(width: 700, height: 400)
        .onAppear {
            var ws1 = Workstream()
            ws1.issueKey = "JWT-134"
            ws1.title = "Adding new columns to the beef view"
            
//            ws1.appendUpdate(
//                .today,
//                body: "Added a new column for the 'Flavor' column"
//            )
//            ws1.appendUpdate(
//                .today,
//                body: "Talked to mgr about how to make it easier to filter by flavor"
//            )
            workspace.streams.append(ws1)
            var ws2 = Workstream()
            ws2.issueKey = "JWT-135"
            ws2.title = "Adding new flavors to the beef model"
            workspace.streams.append(ws2)
            
//            stand.addWorkstream(ws1)
//            stand.addWorkstream(ws2)
        }
}
