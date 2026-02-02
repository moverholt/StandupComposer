//
//  Prev24StreamView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/3/26.
//

import SwiftUI

struct Prev24StreamView: View {
    @Environment(WorkspaceOverlayViewModel.self) var ovm

    @Binding var stream: Workstream

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
//            let plans = stream.plans.complete.noCompletedStandId
//            VStack(alignment: .leading) {
//                Text("Plans Completed Since Last Standup")
//                    .foregroundStyle(.secondary)
//                if plans.isEmpty {
//                    Text("None")
//                } else {
//                    ForEach(plans) { pln in
//                        HStack {
////                            Toggle(
////                                "Completed",
////                                isOn: Binding(
////                                    get: { pln.dayComplete != nil },
////                                    set: {
////                                        stream.togglePlanComplete(
////                                            pln.id,
////                                            $0 ? .today : nil
////                                        )
////                                    }
////                                )
////                            )
////                            .toggleStyle(.checkbox)
////                            .labelsHidden()
////                            .controlSize(.small)
//                            Text(pln.body)
//                                .font(.title3)
//                        }
//                    }
//                }
//            }
//            let updates = stream.updates.noStandup
//            VStack(alignment: .leading) {
//                Text("Updates Since Last Standup")
//                    .foregroundStyle(.secondary)
//                if updates.isEmpty {
//                    Text("None")
//                } else {
//                    ForEach(updates) { upd in
//                        HStack {
//                            Image(systemName: "circle.fill")
//                                .font(.footnote)
//                            Text(upd.body)
//                                .font(.title3)
//                        }
//                    }
//                }
//                HStack {
//                    Spacer()
//                    Button {
//                        ovm.showWorkstreamAddUpdate(stream.id, standId: nil)
//                    } label: {
//                        Label("Add Update", systemImage: "plus")
//                    }
//                    .controlSize(.small)
//                    .buttonStyle(.borderless)
//                }
//            }
        }
    }
}

#Preview {
    @Previewable @State var stream = Workstream(UUID())
    Prev24StreamView(stream: $stream)
        .environment(WorkspaceOverlayViewModel())
        .frame(width: 360)
        .onAppear {
            stream.title = "Sample Workstream"
            stream.issueKey = "FOOD-10"
//            stream.appendUpdate(.today, body: "Met with product manager")
        }
}
