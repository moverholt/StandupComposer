//
//  WSPlanRowView.swift
//  Standups
//
//  Created by OpenAI on 2026-01-01.
//

import SwiftUI

struct WSPlanRowView: View {
    @Binding var ws: Workstream
    @Binding var stand: Standup

    @State private var planText: String = ""

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                if let key = ws.issueKey {
                    Text(key)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(ws.title)
                    .font(.headline)
            }
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(.today)
    @Previewable @State var ws: Workstream = {
        var w = Workstream()
        w.issueKey = "JWT-200"
        w.title = "Prototype planning row"
        return w
    }()

    return WSPlanRowView(ws: $ws, stand: $stand)
        .padding()
        .frame(width: 600)
}
