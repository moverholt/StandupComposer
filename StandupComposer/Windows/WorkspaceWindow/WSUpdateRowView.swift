//
//  WSUpdateRowView.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import SwiftUI

struct WSUpdateRowView: View {
    @Environment(WorkspaceOverlayViewModel.self) var ovm
    
    let stream: Workstream
    @Binding var stand: Standup

    private var streamUpdateIndex: Int? {
//        stand.prevDay.findIndex(wsid: stream.id)
        nil
    }
    
    private var updates: [Workstream.Entry] {
//        stream.updates.forStand(stand.id)
        []
    }
    
//    private var completedPlans: [Workstream.Plan] {
//        stream.plans.completedForStand(stand.id)
//    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(stream.title)
                        .font(.title)
                    Spacer()
                    if let key = stream.issueKey {
                        Text(key)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                Divider()
                    .padding(.bottom)
            }
            HStack(alignment: .top, spacing: 24) {
                VStack {
                    GroupBox(
                        label: Label(
                            "Completed Since Last Standup",
                            systemImage: "checkmark.circle"
                        )
                    ) {
//                        VStack(alignment: .leading, spacing: 6) {
//                            if completedPlans.isEmpty {
//                                Text("None")
//                            } else {
//                                ForEach(completedPlans) { u in
//                                    HStack {
//                                        Image(systemName: "checkmark")
//                                            .font(.footnote)
//                                        Text(u.body)
//                                            .font(.title3)
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    GroupBox(
                        label: Label(
                            "Updates Since Last Standup",
                            systemImage: "clock"
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 6) {
                            if updates.isEmpty {
                                Text("None")
                            } else {
                                ForEach(updates) { u in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.footnote)
                                        Text(u.body)
                                            .font(.title3)
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        HStack {
                            Button(action: {
                                ovm.showWorkstreamAddUpdate(
                                    stream.id
                                )
                            }) {
                                Label("Add update", systemImage: "plus.circle")
                            }
                            .buttonStyle(.borderless)
                            .controlSize(.small)
                            Spacer()
                        }
                    }
                }
//                if let i = streamUpdateIndex {
//                    GroupBox(
//                        label: Label(
//                            "AI Summary",
//                            systemImage: "sparkles.rectangle.stack"
//                        )
//                    ) {
//                        UpdateGeneratorView(
//                            update: $stand.prevDay[i],
//                            prompt: wsUpdatePrompt(
//                                stream,
//                                completedPlans,
//                                updates,
//                            )
//                        )
//                        .frame(maxWidth: .infinity, alignment: .topLeading)
//                    }
//                }
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    @Previewable @State var stream = Workstream(UUID())
    @Previewable @State var stand = Standup(UUID())
    WSUpdateRowView(stream: stream, stand: $stand)
        .padding()
        .frame(width: 600, height: 300)
        .environment(WorkspaceOverlayViewModel())
        .onAppear {
            stream.issueKey = "FOOD-1234"
//            stream.appendUpdate(.today, body: "Added new pasta types")
        }
}
