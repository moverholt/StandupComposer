//
//  WorkstreamPickerPopover.swift
//  StandupComposer
//

import SwiftUI

struct WorkstreamPickerPopover: View {
    @Binding var space: Workspace
    let stand: Standup

    var body: some View {
        List(space.streams) { stream in
            Toggle(
                isOn: Binding(
                    get: { stand.entries.contains(where: { $0.workstreamId == stream.id }) },
                    set: { included in
                        var updatedStand = stand
                        if included {
                            let _ = updatedStand.addWorkstream(stream)
                        } else {
                            updatedStand.removeWorkstream(stream.id)
                        }
                        space.updateStandup(updatedStand)
                    }
                )
            ) {
                HStack(spacing: 6) {
                    Text(stream.title)
                    if let key = stream.issueKey {
                        Text(key)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toggleStyle(.checkbox)
        }
        .listStyle(.inset)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stand = space.stands.last {
            WorkstreamPickerPopover(space: $space, stand: stand)
                .frame(minWidth: 220, minHeight: 200)
        }
    }
    .onAppear {
        let _ = space.createWorkstream("Workstream 1", "WORK-1")
        let _ = space.createWorkstream("Workstream 2", "WORK-2")
        let stand1Id = space.createStandup("Standup 1")
        space.publishStandup(stand1Id)
    }
}
