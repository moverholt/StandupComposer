//
//  StandDocPlanView.swift
//  StandupComposer
//
//  Created by Assistant on 1/25/26.
//

import SwiftUI

//struct StandDocPlanView: View {
//    @Binding var stream: Workstream
//    let stand: Standup
//    let plan: Workstream.Plan
//    
//    var body: some View {
//        Toggle(
//            isOn: Binding(
//                get: { plan.dayComplete != nil },
//                set: { _ in
////                    stream.updatePlanComplete(
////                        $0,
////                        plan.id,
////                        stand.id
////                    )
//                }
//            )
//        ) {
//            Text(plan.body)
//        }
//        .toggleStyle(.checkbox)
//    }
//}
//
//#Preview {
//    @Previewable @State var stream = Workstream()
//    let plan = Workstream.Plan(
//        .today,
//        body: "Complete the authentication flow implementation",
//        number: 1
//    )
//    let stand = Standup()
//    StandDocPlanView(stream: $stream, stand: stand, plan: plan)
//        .padding()
//}
