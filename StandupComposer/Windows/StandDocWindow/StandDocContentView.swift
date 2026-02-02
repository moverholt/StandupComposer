//
//  StandDocContentView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/24/26.
//

import SwiftUI

enum OverlayMode {
    case update
    case plan
}

struct StandDocContentView: View {
    @Binding var space: Workspace
    @Binding var stand: Standup
    
    @State private var showPrevDayPopover = false
    @State private var showTodayPopover = false
    @State private var showUpdateOverlay = false
    @State private var updateText = ""
    @State private var editingWorkstreamId: Workstream.ID?
    @State private var overlayMode: OverlayMode?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        TextField("Title", text: $stand.title)
                        .font(.title)
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("-24")
                                .font(.largeTitle)
                            Spacer()
                            Button(
                                action: {
                                    showPrevDayPopover = true
                                }
                            ) {
                                Label(
                                    "Edit Workstreams",
                                    systemImage: "list.bullet"
                                )
                            }
                            .buttonStyle(.link)
                            .controlSize(.small)
//                            .popover(isPresented: $showPrevDayPopover) {
//                                WorkstreamSelectionPopover(
//                                    space: $space,
//                                    stand: $stand,
//                                    section: .prevDay
//                                )
//                            }
                        }
                        Divider()
//                        let streamIds = stand.streamUpdates.keys.sorted()
//                        ForEach(streamIds, id: \.self) { streamId in
//                            if let stream = space.getStream(streamId) {
//                                let streamUpdates = space.getStandStreamUpdates(
//                                    standId: stand.id
//                                )
//                                let streamCompl = space.getStandCompletedPlans(
//                                    standId: stand.id
//                                )
//                                VStack(alignment: .leading) {
//                                    VStack(alignment: .leading) {
//                                        Text(stream.title)
//                                            .font(.title)
//                                            .foregroundStyle(.secondary)
//                                        if let ik = stream.issueKey {
//                                            Text(ik)
//                                                .font(.footnote.monospaced())
//                                                .foregroundStyle(.tertiary)
//                                        }
//                                    }
//                                    HStack {
//                                        GroupBox {
//                                            let plns = streamCompl[stream.id] ?? []
//                                            if plns.isEmpty {
//                                                Text("None")
//                                                    .foregroundStyle(.secondary)
//                                            } else {
//                                                VStack(alignment: .leading) {
//                                                    ForEach(plns) {
//                                                        pln in
//                                                        HStack {
//                                                            Toggle(
//                                                                "Completed",
//                                                                isOn: Binding(
//                                                                    get: { pln.completed },
//                                                                    set: {
//                                                                        space.updatePlanComplete(
//                                                                            $0,
//                                                                            planId: pln.id,
//                                                                            streamId: stream.id,
//                                                                            standId: stand.id
//                                                                        )
//                                                                    }
//                                                                )
//                                                            )
//                                                            .toggleStyle(.checkbox)
//                                                            .labelsHidden()
//                                                            Text(pln.body)
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        } label: {
//                                            Text("Completed Plans")
//                                                .font(.headline)
//                                        }
//                                        .frame(
//                                            maxWidth: .infinity,
//                                            alignment: .leading
//                                        )
//                                        GroupBox {
//                                            let upds = streamUpdates[stream.id] ?? []
//                                            if upds.isEmpty {
//                                                Text("None")
//                                                    .foregroundStyle(.secondary)
//                                            } else {
//                                                VStack(alignment: .leading) {
//                                                    ForEach(upds) {
//                                                        upd in
//                                                        Text(upd.body)
//                                                    }
//                                                }
//                                            }
//                                            Button(
//                                                action: {
//                                                    overlayMode = .update
//                                                    editingWorkstreamId = stream.id
//                                                    updateText = ""
//                                                    showUpdateOverlay = true
//                                                }
//                                            ) {
//                                                Label(
//                                                    "Add Update",
//                                                    systemImage: "plus"
//                                                )
//                                            }
//                                            .buttonStyle(.link)
//                                            .controlSize(.small)
//                                        } label: {
//                                            Text("Updates")
//                                                .font(.headline)
//                                        }
//                                        .frame(
//                                            maxWidth: .infinity,
//                                            alignment: .leading
//                                        )
//                                    }
//                                }
//                            }
//                        }
                    }
                    Divider()
                    VStack(alignment: .leading) {
                        HStack {
                            Text("+24")
                                .font(.largeTitle)
                            Spacer()
                            Button(
                                action: {
                                    showTodayPopover = true
                                }
                            ) {
                                Label(
                                    "Edit Workstreams",
                                    systemImage: "list.bullet"
                                )
                            }
                            .buttonStyle(.link)
                            .controlSize(.small)
//                            .popover(isPresented: $showTodayPopover) {
//                                WorkstreamSelectionPopover(
//                                    space: $space,
//                                    stand: $stand,
//                                    section: .today
//                                )
//                            }
                        }
                        Divider()
//                        let streamIds = stand.incompletePlans.keys.sorted()
//                        ForEach(streamIds, id: \.self) { streamId in
//                            if let stream = space.getStream(streamId) {
//                                let incomPlns = space.getStandIncompletePlans(
//                                    standId: stand.id
//                                )
//                                VStack(alignment: .leading) {
//                                    VStack(alignment: .leading) {
//                                        Text(stream.title)
//                                            .font(.title)
//                                            .foregroundStyle(.secondary)
//                                        if let ik = stream.issueKey {
//                                            Text(ik)
//                                                .font(.footnote.monospaced())
//                                                .foregroundStyle(.tertiary)
//                                        }
//                                    }
//                                    HStack {
//                                        GroupBox {
//                                            let plans = incomPlns[streamId] ?? []
//                                            if plans.isEmpty {
//                                                Text("None")
//                                                    .foregroundStyle(.secondary)
//                                            } else {
//                                                VStack(alignment: .leading) {
//                                                    ForEach(plans) { pln in
//                                                        HStack {
//                                                            Toggle(
//                                                                "Completed",
//                                                                isOn: Binding(
//                                                                    get: { pln.completed },
//                                                                    set: {
//                                                                        space.updatePlanComplete(
//                                                                            $0,
//                                                                            planId: pln.id,
//                                                                            streamId: stream.id,
//                                                                            standId: stand.id
//                                                                        )
//                                                                    }
//                                                                )
//                                                            )
//                                                            .toggleStyle(.checkbox)
//                                                            .labelsHidden()
//                                                            Text(pln.body)
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                            Button(
//                                                action: {
//                                                    overlayMode = .plan
//                                                    editingWorkstreamId = stream.id
//                                                    updateText = ""
//                                                    showUpdateOverlay = true
//                                                }
//                                            ) {
//                                                Label(
//                                                    "Add Plan",
//                                                    systemImage: "plus"
//                                                )
//                                            }
//                                            .buttonStyle(.link)
//                                            .controlSize(.small)
//                                        } label: {
//                                            Text("Plans")
//                                                .font(.headline)
//                                        }
//                                        .frame(
//                                            maxWidth: .infinity,
//                                            alignment: .leading
//                                        )
//                                    }
//                                }
//                            }
//                        }
                    }
                }
                .scenePadding()
            }
            
            if showUpdateOverlay {
                VStack(spacing: 8) {
                    HStack {
                        if let id = editingWorkstreamId,
                           let stream = space.streams.find(id: id) {
                            if overlayMode == .update {
                                Text("Adding update to: \(stream.title)")
                                    .font(.headline)
                            } else if overlayMode == .plan {
                                Text("Adding plan to: \(stream.title)")
                                    .font(.headline)
                            }
                        }
                        Spacer()
                    }
                    GrowingTextView2UI(
                        text: $updateText,
                        placeholder: overlayMode == .update ? "Enter your update here..." : "Enter your plan here..."
                    ) {
                        handleSubmit()
                    }
                    .border(.separator, width: 1)
                    HStack {
                        Button("Cancel") {
                            handleCancel()
                        }
                        Spacer()
                        Button("Add") {
                            handleSubmit()
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(
                            updateText.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                        )
                    }
                }
                .padding(12)
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
                .shadow(radius: 12)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private func handleSubmit() {
//        guard let id = editingWorkstreamId else { return }
//        let trimmed = updateText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//        
//        if overlayMode == .update {
//            space.addWorkstreamUpdate(id: id, body: trimmed, standId: stand.id)
//        } else if overlayMode == .plan {
//            space.addWorkstreamPlan(id: id, body: trimmed, standId: stand.id)
//        }
//        
//        handleCancel()
    }
    
    private func handleCancel() {
        updateText = ""
        editingWorkstreamId = nil
        overlayMode = nil
        showUpdateOverlay = false
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if space.stands.isEmpty {
            EmptyView()
        } else {
//            StandDocContentView(
//                space: $space,
//                stand: $space.stands[0]
//            )
        }
    }
    .onAppear {
//        var ws1 = Workstream()
//        ws1.title = "Workstream 1"
//        ws1.issueKey = "WS1-1"
//        var ws2 = Workstream()
//        ws2.title = "Workstream 2"
//        ws2.issueKey = "WS1-2"
//        
//        space.streams.append(ws1)
//        space.streams.append(ws2)
//        
//        var stand = Standup()
////        stand.addWorkstream(ws1)
////        stand.addWorkstream(ws2)
//        
////        space.addWorkstreamUpdate(id: ws1.id, body: "This is an update", standId: stand.id)
////        space.addWorkstreamUpdate(id: ws1.id, body: "This is an another update", standId: stand.id)
//        
//        space.addWorkstreamPlan(id: ws1.id, body: "This is a plan", standId: stand.id)
//
//        space.stands.append(stand)
    }
}
