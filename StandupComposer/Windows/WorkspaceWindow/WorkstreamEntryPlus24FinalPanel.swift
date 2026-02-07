import SwiftUI

struct WorkstreamEntryPlus24FinalPanel: View {
    @Environment(WorkspaceOverlayViewModel.self) private var ovm
    @Binding var space: Workspace
    let stand: Standup
    let entry: Standup.WorkstreamEntry

    private func useDraft() {
        guard let draft = entry.plus24Draft, !draft.isEmpty else { return }
        var sp = space
        guard var st = sp.getStand(stand.id),
              let idx = st.entries.firstIndex(where: { $0.id == entry.id })
        else { return }
        st.entries[idx].plus24Final = draft
        st.entries[idx].plus24EditedAt = Date()
        sp.updateStandup(st)
        space = sp
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Final")
                .font(.headline)
                .foregroundStyle(.secondary)

            if let finalText = entry.plus24Final, !finalText.isEmpty {
                Text(finalText)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                ovm.showEditPlus24Final(standId: stand.id, entryId: entry.id, initialText: entry.plus24Final ?? "")
            } label: {
                Label(entry.plus24Final?.isEmpty == false ? "Edit final" : "Add final", systemImage: "pencil.line")
            }
            .buttonStyle(.plain)
            .controlSize(.small)
            .font(.subheadline)
            .foregroundStyle(ovm.showOverlay && ovm.finalPlus24EntryId == entry.id ? Color.accentColor : .secondary)

            Button {
                useDraft()
            } label: {
                Label("Use draft", systemImage: "doc.on.doc")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
            .disabled((entry.plus24Draft?.isEmpty ?? true) || (entry.plus24Final ?? "") == (entry.plus24Draft ?? ""))
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    var stand: Standup? { space.stands.first }
    var entry: Standup.WorkstreamEntry? { stand?.entries.first }

    VStack {
        if let stand, let entry {
            WorkstreamEntryPlus24FinalPanel(space: $space, stand: stand, entry: entry)
        }
    }
    .frame(width: 220, height: 200)
    .environment(UserSettings())
    .environment(WorkspaceOverlayViewModel())
    .onAppear {
        let streamId = space.createWorkstream("Preview Workstream", "PREV-1")
        space.addWorkstreamEntry(streamId, "First update in range")
        let _ = space.createStandup("Preview Standup")
        if var st = space.getStand(space.stands.first!.id), !st.entries.isEmpty {
            st.entries[0].plus24Draft = "Generated draft plan text."
            st.entries[0].plus24Final = "Current final text."
            space.updateStandup(st)
        }
    }
}
