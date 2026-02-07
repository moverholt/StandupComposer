import SwiftUI

struct WorkstreamDraftPanel: View {
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

    private var draftPrompt: String? {
        guard let stream else { return nil }
        return minus24DraftPrompt(
            stream,
            stream.entries(for: stand),
            notes: entry.minus24DraftNotes
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
                space.setMinus24Draft(standId: stand.id, entryId: entry.id, draft: final)
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
                } else if let draft = entry.minus24Draft, !aiActive {
                    VStack(alignment: .leading, spacing: 6) {
                        ScrollView {
                            Text(draft)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button {
                            Task { await run() }
                        } label: {
                            Label("Refresh summary", systemImage: "arrow.clockwise")
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
                            Label("Generate draft", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        Spacer()
                    }
                }
            }
            .textSelection(.enabled)

            if let notes = entry.minus24DraftNotes, !notes.isEmpty {
                Text(notes)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                ovm.showDraftNotes(standId: stand.id, entryId: entry.id, initialText: entry.minus24DraftNotes ?? "")
            } label: {
                Label(entry.minus24DraftNotes?.isEmpty == false ? "Edit notes" : "Add notes", systemImage: "note.text")
            }
            .buttonStyle(.plain)
            .controlSize(.small)
            .font(.subheadline)
            .foregroundStyle(ovm.showOverlay && ovm.draftNotesEntryId == entry.id ? Color.accentColor : .secondary)
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    var stand: Standup? { space.stands.first }
    var entry: Standup.WorkstreamEntry? { stand?.entries.first }

    VStack {
        if let stand, let entry {
            WorkstreamDraftPanel(space: $space, stand: stand, entry: entry)
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
