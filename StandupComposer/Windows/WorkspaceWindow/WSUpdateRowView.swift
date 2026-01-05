//
//  WSUpdateRowView.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import SwiftUI

struct WSUpdateRowView: View {
    @Binding var ws: Workstream
    @Binding var stand: Standup
    
    private var wsUpdateIndex: Int? {
        stand.updates.findIndex(wsid: ws.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
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
            .padding(.bottom, 12)
            HStack(alignment: .top) {
                GroupBox(
                    label: Label(
                        "Updates since last standup",
                        systemImage: "list.bullet"
                    )
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        if ws.updates.isEmpty {
                            Text("No recorded updates since last standup")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        } else {
                            ForEach(ws.updates.available) { u in
                                HStack {
                                    Text(u.body)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                if let i = wsUpdateIndex {
                    GroupBox(
                        label: Label(
                            "Generated Update",
                            systemImage: "brain"
                        )
                    ) {
                        UpdateGeneratorView(update: $stand.updates[i], ws: $ws)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var ws = Workstream()
    @Previewable @State var stand = Standup(.today)
    WSUpdateRowView(ws: $ws, stand: $stand)
        .padding()
        .frame(width: 600, height: 300)
        .onAppear {
            ws.issueKey = "FOOD-1234"
            ws.appendUpdate(
                .today,
                body: "Added new pasta types"
            )
        }
}
