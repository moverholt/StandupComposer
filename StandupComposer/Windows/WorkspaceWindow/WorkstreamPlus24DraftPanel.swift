import SwiftUI

struct WorkstreamPlus24DraftPanel: View {
    @Environment(UserSettings.self) var settings
    @Environment(WorkspaceOverlayViewModel.self) private var ovm
    @Binding var space: Workspace
    let stand: Standup
    let entry: Standup.WorkstreamEntry

    @State private var aiActive = false
    @State private var aiPartial: String?
    @State private var aiError: String?

    private var stream: Workstream? {
        space.getStream(entry.workstreamId)
    }

    private var updatesInRange: [Workstream.Entry] {
        stream?.entries(for: stand) ?? []
    }

    private var draftPrompt: String? {
        guard let stream else { return nil }
        return plus24DraftPrompt(
            stream,
            updatesInRange,
            notes: entry.plus24DraftNotes
        )
    }

    private func run() async {
        aiError = nil
        aiPartial = nil
        aiActive = true
        guard let draftPrompt else {
            aiError = "No workstream"
            aiActive = false
            return
        }
        let chatStream = streamOpenAIChat(
            prompt: draftPrompt,
            config: OpenAIConfig(settings)
        )
        do {
            var final: String?
            for try await partial in chatStream {
                aiPartial = partial
                final = partial
            }
            aiActive = false
            if let final {
                var sp = space
                sp.setPlus24Draft(standId: stand.id, entryId: entry.id, draft: final)
                space = sp
            }
            aiPartial = nil
        } catch {
            aiError = error.localizedDescription
            aiActive = false
            aiPartial = nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Draft")
                .font(.headline)
                .foregroundStyle(.secondary)

            ZStack(alignment: .center) {
                Color.clear
                if let err = aiError {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(err)
                            .foregroundStyle(.red)
                        Button {
                            Task { await run() }
                        } label: {
                            Label("Try Again", systemImage: "arrow.clockwise")
                        }
                    }
                } else if let draft = entry.plus24Draft, !aiActive {
                    VStack(alignment: .leading, spacing: 6) {
                        ScrollView {
                            Text(draft)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button {
                            Task { await run() }
                        } label: {
                            Label("Refresh plan", systemImage: "arrow.clockwise")
                        }
                        .controlSize(.small)
                        .buttonStyle(.borderless)
                    }
                } else if aiActive {
                    VStack(alignment: .leading) {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                            Spacer()
                        }
                        Text(aiPartial ?? "")
                        Spacer()
                    }
                } else {
                    HStack {
                        Button {
                            Task {
                                await run()
                            }
                        } label: {
                            Label("Suggest plan", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        Spacer()
                    }
                }
            }
            .textSelection(.enabled)

            if let notes = entry.plus24DraftNotes, !notes.isEmpty {
                Text(notes)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                ovm.showPlus24DraftNotes(standId: stand.id, entryId: entry.id, initialText: entry.plus24DraftNotes ?? "")
            } label: {
                Label(entry.plus24DraftNotes?.isEmpty == false ? "Edit notes" : "Add notes", systemImage: "note.text")
            }
            .buttonStyle(.plain)
            .controlSize(.small)
            .font(.subheadline)
            .foregroundStyle(ovm.showOverlay && ovm.draftNotesPlus24EntryId == entry.id ? Color.accentColor : .secondary)
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    var stand: Standup? { space.stands.first }
    var entry: Standup.WorkstreamEntry? { stand?.entries.first }

    VStack {
        if let stand, let entry {
            WorkstreamPlus24DraftPanel(space: $space, stand: stand, entry: entry)
        }
    }
    .frame(width: 220, height: 320)
    .environment(UserSettings())
    .environment(WorkspaceOverlayViewModel())
    .onAppear {
        let streamId = space.createWorkstream("Preview Workstream", "PREV-1")
        space.addWorkstreamEntry(streamId, "First update in range")
        space.addWorkstreamEntry(streamId, "Second update in range")
        let _ = space.createStandup("Preview Standup")
    }
}
