import SwiftUI

struct Next24StreamView: View {
    @Environment(WorkspaceOverlayViewModel.self) var ovm
    
    @Binding var stream: Workstream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
//            let plans = stream.plans.incomplete
//            VStack(alignment: .leading) {
//                Text("Planned Work for Next Standup")
//                    .foregroundStyle(.secondary)
//                
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
////                            Text(pln.body)
////                                .font(.title3)
//                        }
//                    }
//                }
//                
//                HStack {
//                    Spacer()
//                    Button {
//                        ovm.showWorkstreamAddPlan(stream.id, standId: nil)
//                    } label: {
//                        Label("Add Plan", systemImage: "plus")
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
    
    Next24StreamView(stream: $stream)
        .frame(width: 360)
        .environment(WorkspaceOverlayViewModel())
        .onAppear {
            stream.title = "Sample Workstream"
            stream.issueKey = "FOOD-42"
//            stream.appendPlan("Draft test plan for tomorrow")
        }
}
