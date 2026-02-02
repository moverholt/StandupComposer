import SwiftUI

struct WorkstreamEntryPlus24FinalPanel: View {
    @Binding var space: Workspace
    let stand: Standup
    let entry: Standup.WorkstreamEntry

    private var finalBinding: Binding<String> {
        Binding(
            get: { entry.plus24Final ?? "" },
            set: { newValue in
                var sp = space
                guard var st = sp.getStand(stand.id),
                      let idx = st.entries.firstIndex(where: { $0.id == entry.id })
                else { return }
                st.entries[idx].plus24Final = newValue.isEmpty ? nil : newValue
                sp.updateStandup(st)
                space = sp
            }
        )
    }

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

            TextField("Final text …", text: finalBinding, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4, reservesSpace: true)

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
