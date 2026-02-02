import SwiftUI

struct WorkstreamEntryPlus24View: View {
    @Binding var space: Workspace
    let stand: Standup
    let entry: Standup.WorkstreamEntry

    var body: some View {
        if space.getStream(entry.workstreamId) == nil {
            Text("No workstream")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
        } else {
            HStack(alignment: .top, spacing: 0) {
                WorkstreamPlus24DraftPanel(space: $space, stand: stand, entry: entry)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)

                Divider()

                WorkstreamEntryPlus24FinalPanel(space: $space, stand: stand, entry: entry)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    var stand: Standup? { space.stands.first }
    var entry: Standup.WorkstreamEntry? { stand?.entries.first }

    VStack {
        if let stand, let entry {
            WorkstreamEntryPlus24View(space: $space, stand: stand, entry: entry)
        }
    }
    .padding()
    .frame(width: 500, height: 300)
    .environment(WorkspaceOverlayViewModel())
    .environment(UserSettings())
    .onAppear {
        let streamId = space.createWorkstream("Preview Workstream", "PREV-1")
        space.addWorkstreamEntry(streamId, "First update in range")
        space.addWorkstreamEntry(streamId, "Second update in range")
        let _ = space.createStandup("Preview Standup")
    }
}
