import SwiftUI

struct WorkstreamEntryUpdatesPanel: View {
    @Environment(WorkspaceOverlayViewModel.self) private var ovm

    @Binding var space: Workspace
    
    let stand: Standup
    let entry: Standup.WorkstreamEntry

    private var updatesInRange: [Workstream.Entry] {
        space.getStream(entry.workstreamId)?.entries(for: stand) ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Updates")
                .font(.headline)
                .foregroundStyle(.secondary)
            if updatesInRange.isEmpty {
                Text("No updates in this range")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(updatesInRange) { update in
                        Text(update.body)
                            .textSelection(.enabled)
                    }
                }
            }
            Button {
                ovm.showWorkstreamAddUpdate(entry.workstreamId)
            } label: {
                Label("Add update", systemImage: "plus.circle")
            }
            .buttonStyle(.plain)
            .controlSize(.small)
            .font(.subheadline)
            .foregroundStyle(ovm.showOverlay && ovm.workstreamAddUpdateId == entry.workstreamId ? Color.accentColor : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    var stand: Standup? { space.stands.first }
    var entry: Standup.WorkstreamEntry? { stand?.entries.first }

    VStack {
        if let stand, let entry {
            WorkstreamEntryUpdatesPanel(space: $space, stand: stand, entry: entry)
        }
    }
    .padding()
    .frame(width: 280, height: 200)
    .environment(WorkspaceOverlayViewModel())
    .onAppear {
        let streamId = space.createWorkstream("Preview Workstream", "PREV-1")
        space.addWorkstreamEntry(streamId, "First update in range")
        space.addWorkstreamEntry(streamId, "Second update in range")
        let _ = space.createStandup("Preview Standup")
    }
}
