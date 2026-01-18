//
//  WorkstreamDetailPlansScrollview.swift
//  StandupComposer
//
//  Created by Assistant on 1/18/26.
//

import SwiftUI

struct WorkstreamDetailPlansScrollview: View {
    @Binding var stream: Workstream
    
    private var activePlans: [Workstream.Plan] {
        stream.plans.filter({
            $0.dayComplete == nil ||
            $0.dayComplete == .today ||
            $0.completedStandId == nil
        })
    }
    
    private var previousPlans: [Workstream.Plan] {
        let ids = activePlans.map(\.id)
        return stream.plans.filter({ !ids.contains($0.id) })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if !previousPlans.isEmpty {
                    Text("Previous Plans")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                    WorkstreamPlansList(
                        plans: previousPlans,
                        stream: $stream
                    )
                }
                Text("Active Plans")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                if activePlans.isEmpty {
                    Text("None")
                } else {
                    WorkstreamPlansList(
                        plans: activePlans,
                        stream: $stream
                    )
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var s1 = Workstream()
    WorkstreamDetailPlansScrollview(stream: $s1)
        .onAppear {
            s1.title = "Sample Stream"
            s1.appendPlan("Investigate crash in module A")
            s1.appendPlan("Ship 1.2.3 to TestFlight")
            s1.appendPlan("Write postmortem for outage")
        }
}
