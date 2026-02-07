//
//  EditStandHeaderView.swift
//  StandupComposer
//

import SwiftUI

struct EditStandHeaderView: View {
    @Binding var space: Workspace
    let stand: Standup

    @State private var showWorkstreamPicker = false
    @State private var showPreviousStandPopover = false

    private var timeRangeDescription: String {
        let startText = stand.rangeStart.formatted(date: .abbreviated, time: .omitted)
        let endText: String
        if let end = stand.rangeEnd {
            endText = end.formatted(date: .abbreviated, time: .omitted)
        } else {
            endText = "Current"
        }
        return "\(startText) – \(endText)"
    }

    private var workstreamCount: Int {
        stand.entries.count
    }

    private var totalEntryCount: Int {
        stand.entries.reduce(0) { sum, entry in
            sum + (space.getStream(entry.workstreamId).map { $0.entries(for: stand).count } ?? 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let prev = space.getStand(stand.previousStandupId) {
                    HStack(spacing: 4) {
                        Text("Previous standup: ")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            showPreviousStandPopover = true
                        } label: {
                            Text(prev.title)
                                .underline()
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .popover(
                            isPresented: $showPreviousStandPopover,
                            arrowEdge: .top
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(prev.title)
                                    .font(.headline)
                                if let formatted = prev.formattedSlack, !formatted.isEmpty {
                                    ScrollView {
                                        SelectableFormattedTextView(
                                            content: formatted,
                                            selectAllRequested: .constant(false)
                                        )
                                        .frame(minHeight: 240)
                                    }
                                    .frame(minWidth: 360, minHeight: 280)
                                } else {
                                    Text("No formatted content for this standup.")
                                        .foregroundStyle(.secondary)
                                        .padding()
                                        .frame(minWidth: 280, minHeight: 80)
                                }
                            }
                            .padding(12)
                            .frame(minWidth: 360)
                        }
                    }
                } else {
                    Text("This is the first standup")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    showWorkstreamPicker = true
                } label: {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.borderless)
                .popover(
                    isPresented: $showWorkstreamPicker,
                    arrowEdge: .top
                ) {
                    WorkstreamPickerPopover(space: $space, stand: stand)
                        .frame(minWidth: 220, minHeight: 200)
                }
            }
            Text("Period: \(timeRangeDescription) · \(workstreamCount) workstreams · \(totalEntryCount) entries")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    var stand: Standup? {
        space.stands.last
    }

    VStack(alignment: .leading) {
        if let stand {
            EditStandHeaderView(space: $space, stand: stand)
        }
    }
    .frame(width: 500)
    .padding()
    .environment(UserSettings())
    .onAppear {
        let ws1Id = space.createWorkstream("Workstream 1", "WORK-1")
        let ws2Id = space.createWorkstream("Workstream 2", "WORK-2")
        let stand1Id = space.createStandup("Standup 1")
        space.publishStandup(stand1Id)
        space.addWorkstreamEntry(ws1Id, "First update")
        space.addWorkstreamEntry(ws1Id, "Second update")
        space.addWorkstreamEntry(ws2Id, "Another update")
        let _ = space.createStandup("Standup 2")
        if var st = space.getStand(space.stands.last!.id), !st.entries.isEmpty {
            st.entries[0].minus24Draft = "Draft"
            space.updateStandup(st)
        }
    }
}
