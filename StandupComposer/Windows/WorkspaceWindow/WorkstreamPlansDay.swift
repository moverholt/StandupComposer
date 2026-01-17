import SwiftUI

struct WorkstreamPlansDay: View {
    let plans: [Workstream.Plan]
    @Binding var stream: Workstream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plans")
                .font(.title2)
                .foregroundStyle(.secondary)
            VStack {
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
                        }
                        Spacer()
                        Menu {
                            Button(role: .destructive) {
                                stream.deletePlan(plan)
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
}

#Preview {
    @Previewable @State var stream = Workstream()
    
    WorkstreamPlansDay(plans: stream.plansByDay[.today] ?? [], stream: $stream)
        .scenePadding()
        .onAppear {
            if stream.plans.isEmpty {
                stream.plans.append(.today, "This is a plan")
                stream.plans.append(.today, "Another plan for today")
            }
        }
}
