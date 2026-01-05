//
//  StandFormattedView.swift
//  StandupComposer
//
//  Created by Developer on 2025-12-29.
//

import SwiftUI

struct StandFormattedView: View {
    let stand: Standup

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(stand.title)
                    .font(.title2)
                    .bold()
                Divider()
                Text("-24")
                    .font(.largeTitle.weight(.semibold))
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(stand.updates) { upd in
                        HStack(alignment: .center, spacing: 6) {
                            if let ik = upd.ws.issueKey {
                                Text("[\(ik)]")
                                    .foregroundStyle(.secondary)
                                    .fontDesign(.monospaced)
                                    .font(.body.weight(.light))
                            }
                            Text(upd.ws.title)
                                .font(.title.weight(.semibold))
                            Text(upd.body ?? "No update")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .textSelection(.enabled)
        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(.today)
    StandFormattedView(stand: stand)
        .frame(width: 600, height: 400)
        .onAppear {
            var ws1 = Workstream()
            ws1.issueKey = "ZZZZ-9998"
            var up1 = Standup.WorkstreamUpdate(ws1)
            up1.body = "This is a test update."
            stand.updates.append(up1)
            
            var ws2 = Workstream()
            ws2.issueKey = "ZZZZ-9999"
            var up2 = Standup.WorkstreamUpdate(ws2)
            up2.body = "This is another test update."
            stand.updates.append(up2)
        }
}
