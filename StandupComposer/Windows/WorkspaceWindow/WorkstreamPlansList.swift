import SwiftUI

struct WorkstreamPlansList: View {
    let plans: [Workstream.Plan]
    @Binding var stream: Workstream
    
    var body: some View {
        LazyVStack {
            ForEach(plans) { plan in
                HStack(alignment: .center) {
                    Toggle(
                        "Completed",
                        isOn: Binding(
                            get: { plan.dayComplete != nil },
                            set: {
                                stream.togglePlanComplete(
                                    plan.id,
                                    $0 ? .today : nil
                                )
                            }
                        )
                    )
                    .toggleStyle(.checkbox)
                    .labelsHidden()
                    Text(plan.body)
                        .textSelection(.enabled)
                    if let dc = plan.dayComplete {
                        Text(dc.formatted(style: .abbreviated))
                            .foregroundStyle(.tertiary)
                            .font(.caption)
                    }
                    Spacer()
                    Menu {
                        Button(role: .destructive) {
                            stream.deletePlan(plan.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .imageScale(.medium)
                            .padding(6)
                            .contentShape(Rectangle())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.separator, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var stream = Workstream()
    WorkstreamPlansList(plans: stream.plans, stream: $stream)
        .onAppear {
            stream.appendPlan("This is a plan")
            stream.appendPlan("Another plan for today")
        }
}
