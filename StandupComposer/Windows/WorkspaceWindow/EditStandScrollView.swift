//
//  EditStandScrollView.swift
//  StandupComposer
//
//  Created by OpenAI on 2025-12-28.
//

import SwiftUI

struct EditStandScrollView: View {
    @Binding var stand: Standup
    @Binding var streams: [Workstream]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("-24")
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                    Spacer()
                }
                Divider()
                    .padding(.bottom)
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(stand.updates) { upd in
                        if let i = streams.findIndex(id: upd.ws.id) {
                            WSUpdateRowView(ws: $streams[i], stand: $stand)
                        }
                    }
                }
                .padding(.bottom)
                HStack {
                    Text("+24")
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                    Spacer()
                }
                Divider()
                    .padding(.bottom)
                VStack {
                    ForEach(stand.updates) { upd in
                        if let i = streams.findIndex(id: upd.ws.id) {
                            WSPlanRowView(ws: $streams[i], stand: $stand)
                        }
                    }
                }
                Spacer()
            }
            .padding(6)
        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(.today)
    @Previewable @State var streams: [Workstream] = []
    EditStandScrollView(stand: $stand, streams: $streams)
        .padding()
        .frame(width: 700, height: 400)
        .onAppear {
            var ws1 = Workstream()
            ws1.issueKey = "JWT-134"
            ws1.title = "Adding new columns to the beef view"
            
            ws1.appendUpdate(
                .today,
                body: "Added a new column for the 'Flavor' column"
            )
            ws1.appendUpdate(
                .today,
                body: "Talked to mgr about how to make it easier to filter by flavor"
            )
            streams.append(ws1)
            var ws2 = Workstream()
            ws2.issueKey = "JWT-135"
            ws2.title = "Adding new flavors to the beef model"
            streams.append(ws2)
        }
}
