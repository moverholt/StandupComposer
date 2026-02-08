import SwiftUI

struct WorkspaceQuickInputOverlay: View {
    @Environment(WorkspaceOverlayViewModel.self) private var ovm
    @Binding var space: Workspace

    @FocusState private var focus: Bool
    
    private var isDraftNotes: Bool {
        ovm.draftNotesEntryId != nil || ovm.draftNotesPlus24EntryId != nil
    }
    
    private var isEditFinal: Bool {
        ovm.finalEntryId != nil || ovm.finalPlus24EntryId != nil
    }
    
    private var isSaveMode: Bool {
        isDraftNotes || isEditFinal
    }
    
    private var overlayPlaceholder: String {
        if isEditFinal { return "Final text…" }
        if isDraftNotes { return "Add notes…" }
        return "Type something here"
    }

    private var overlayTitle: String {
        if ovm.finalPlus24EntryId != nil { return "Final (+24)" }
        if ovm.finalEntryId != nil { return "Final" }
        if ovm.draftNotesEntryId != nil || ovm.draftNotesPlus24EntryId != nil { return "Draft Notes" }
        if ovm.workstreamAddUpdateId != nil { return "New Update" }
        return ""
    }

    private func submitOverlay() {
        let trimmed = ovm.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let standId = ovm.finalStandId, let entryId = ovm.finalEntryId {
            var sp = space
            guard var st = sp.getStand(standId),
                  let idx = st.entries.firstIndex(where: { $0.id == entryId })
            else {
                ovm.close()
                return
            }
            st.entries[idx].minus24Final = trimmed.isEmpty ? nil : trimmed
            st.entries[idx].minus24EditedAt = Date()
            sp.updateStandup(st)
            space = sp
        } else if let standId = ovm.finalPlus24StandId, let entryId = ovm.finalPlus24EntryId {
            var sp = space
            guard var st = sp.getStand(standId),
                  let idx = st.entries.firstIndex(where: { $0.id == entryId })
            else {
                ovm.close()
                return
            }
            st.entries[idx].plus24Final = trimmed.isEmpty ? nil : trimmed
            st.entries[idx].plus24EditedAt = Date()
            sp.updateStandup(st)
            space = sp
        } else if let standId = ovm.draftNotesStandId, let entryId = ovm.draftNotesPlus24EntryId {
            var sp = space
            guard var st = sp.getStand(standId),
                  let idx = st.entries.firstIndex(where: { $0.id == entryId })
            else {
                ovm.close()
                return
            }
            st.entries[idx].plus24DraftNotes = trimmed.isEmpty ? nil : trimmed
            sp.updateStandup(st)
            space = sp
        } else if let standId = ovm.draftNotesStandId, let entryId = ovm.draftNotesEntryId {
            var sp = space
            guard var st = sp.getStand(standId),
                  let idx = st.entries.firstIndex(where: { $0.id == entryId })
            else {
                ovm.close()
                return
            }
            st.entries[idx].minus24DraftNotes = trimmed.isEmpty ? nil : trimmed
            sp.updateStandup(st)
            space = sp
        } else if !trimmed.isEmpty, let id = ovm.workstreamAddUpdateId {
            space.addWorkstreamEntry(id, trimmed)
        }
        ovm.close()
    }

    var body: some View {
        @Bindable var ovm = ovm
        VStack(alignment: .leading, spacing: 0) {
            if !overlayTitle.isEmpty {
                Text(overlayTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
            }
            SubmittableTextView(
                text: $ovm.text,
                placeholder: overlayPlaceholder,
                maxLines: 5
            ) {
                submitOverlay()
            }
            .padding(8)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .padding(.bottom, 14)

            HStack(spacing: 8) {
                Button("Cancel") {
                    ovm.close()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.bordered)
                .controlSize(.regular)

                Spacer(minLength: 0)

                if isSaveMode {
                    Button("Save") {
                        submitOverlay()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                } else if ovm.workstreamAddUpdateId != nil {
                    Button("Add") {
                        submitOverlay()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(
                        ovm.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
        .padding(20)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
        .onAppear {
            focus = true
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var ovm = WorkspaceOverlayViewModel()
        @State private var space = Workspace()

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Color.clear
                    .frame(width: 400, height: 400)
                WorkspaceQuickInputOverlay(space: $space)
            }
            .environment(ovm)
            .onAppear {
                ovm.showWorkstreamAddUpdate(Workstream.ID())
            }
        }
    }

    return PreviewWrapper()
}
