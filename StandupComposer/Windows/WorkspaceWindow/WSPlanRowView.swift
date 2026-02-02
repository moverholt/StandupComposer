//
//  WSPlanRowView.swift
//  Standups
//
//  Created by OpenAI on 2026-01-01.
//

import SwiftUI

//struct WSPlanRowView: View {
//    @Environment(WorkspaceOverlayViewModel.self) var ovm
//    
//    let stream: Workstream
//    
//    @Binding var stand: Standup
//
//    private var wsPlanIndex: Int? {
//        stand.today.findIndex(wsid: stream.id)
//    }
//    
//    private var plans: [Workstream.Plan] {
//        stream.plans.forStand(stand.id)
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            VStack(alignment: .leading, spacing: 0) {
//                HStack(alignment: .center, spacing: 0) {
//                    Text(stream.title)
//                        .font(.title)
//                    Spacer()
//                    if let key = stream.issueKey {
//                        Text(key)
//                            .font(.body)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//                Divider()
//                    .padding(.bottom)
//            }
//            HStack(alignment: .top, spacing: 24) {
//                GroupBox(
//                    label: Label(
//                        "Planned Work",
//                        systemImage: "list.bullet.clipboard"
//                    )
//                ) {
//                    VStack(alignment: .leading, spacing: 6) {
//                        if plans.incomplete.isEmpty {
//                            Text("None")
//                        } else {
//                            ForEach(plans.incomplete) { u in
//                                HStack {
//                                    Image(systemName: "circle.fill")
//                                        .font(.footnote)
//                                    Text(u.body)
//                                        .font(.title3)
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .topLeading)
//                    HStack {
//                        Button(
//                            action: {
//                                ovm.showWorkstreamAddPlan(
//                                    stream.id,
//                                    standId: stand.id
//                                )
//                            }
//                        ) {
//                            Label("Add plan", systemImage: "plus.circle")
//                        }
//                        .buttonStyle(.borderless)
//                        .controlSize(.small)
//                        Spacer()
//                    }
//                }
//                if let i = wsPlanIndex {
//                    GroupBox(
//                        label: Label(
//                            "AI Summary",
//                            systemImage: "sparkles.rectangle.stack"
//                        )
//                    ) {
//                        UpdateGeneratorView(
//                            update: $stand.today[i],
//                            prompt: wsPlanPrompt(stream, plans)
//                        )
//                        .frame(maxWidth: .infinity, alignment: .topLeading)
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    @Previewable @State var stand = Standup(.today)
//    @Previewable @State var ws: Workstream = {
//        var w = Workstream()
//        w.issueKey = "JWT-200"
//        w.title = "Prototype planning row"
//        return w
//    }()
//
//    WSPlanRowView(stream: ws, stand: $stand)
//        .padding()
//        .frame(width: 600)
//        .environment(WorkspaceOverlayViewModel())
//        .onAppear {
////            stand.addWorkstream(ws)
//        }
//}
