import SwiftUI

@Observable
class WorkspaceOverlayViewModel {
    var showOverlay = false
    var text: String = ""
    
    var workstreamAddUpdateId: Workstream.ID?
    
    var draftNotesStandId: Standup.ID?
    var draftNotesEntryId: Standup.WorkstreamEntry.ID?
    var draftNotesPlus24EntryId: Standup.WorkstreamEntry.ID?
    var finalStandId: Standup.ID?
    var finalEntryId: Standup.WorkstreamEntry.ID?
    var finalPlus24StandId: Standup.ID?
    var finalPlus24EntryId: Standup.WorkstreamEntry.ID?
    
    func close() {
        showOverlay = false
        text = ""
        workstreamAddUpdateId = nil
        draftNotesStandId = nil
        draftNotesEntryId = nil
        draftNotesPlus24EntryId = nil
        finalStandId = nil
        finalEntryId = nil
        finalPlus24StandId = nil
        finalPlus24EntryId = nil
    }
    
    func showWorkstreamAddUpdate(_ id: Workstream.ID) {
        if workstreamAddUpdateId == id {
            close()
            return
        }
        draftNotesStandId = nil
        draftNotesEntryId = nil
        draftNotesPlus24EntryId = nil
        finalStandId = nil
        finalEntryId = nil
        finalPlus24StandId = nil
        finalPlus24EntryId = nil
        workstreamAddUpdateId = id
        if !showOverlay {
            showOverlay = true
        }
    }
    
    func showDraftNotes(standId: Standup.ID, entryId: Standup.WorkstreamEntry.ID, initialText: String) {
        if draftNotesEntryId == entryId {
            close()
            return
        }
        workstreamAddUpdateId = nil
        draftNotesPlus24EntryId = nil
        finalStandId = nil
        finalEntryId = nil
        finalPlus24StandId = nil
        finalPlus24EntryId = nil
        draftNotesStandId = standId
        draftNotesEntryId = entryId
        text = initialText
        if !showOverlay {
            showOverlay = true
        }
    }
    
    func showPlus24DraftNotes(standId: Standup.ID, entryId: Standup.WorkstreamEntry.ID, initialText: String) {
        if draftNotesPlus24EntryId == entryId {
            close()
            return
        }
        workstreamAddUpdateId = nil
        draftNotesEntryId = nil
        finalStandId = nil
        finalEntryId = nil
        finalPlus24StandId = nil
        finalPlus24EntryId = nil
        draftNotesStandId = standId
        draftNotesPlus24EntryId = entryId
        text = initialText
        if !showOverlay {
            showOverlay = true
        }
    }
    
    func showEditFinal(standId: Standup.ID, entryId: Standup.WorkstreamEntry.ID, initialText: String) {
        if finalEntryId == entryId {
            close()
            return
        }
        workstreamAddUpdateId = nil
        draftNotesStandId = nil
        draftNotesEntryId = nil
        draftNotesPlus24EntryId = nil
        finalPlus24StandId = nil
        finalPlus24EntryId = nil
        finalStandId = standId
        finalEntryId = entryId
        text = initialText
        if !showOverlay {
            showOverlay = true
        }
    }
    
    func showEditPlus24Final(standId: Standup.ID, entryId: Standup.WorkstreamEntry.ID, initialText: String) {
        if finalPlus24EntryId == entryId {
            close()
            return
        }
        workstreamAddUpdateId = nil
        draftNotesStandId = nil
        draftNotesEntryId = nil
        draftNotesPlus24EntryId = nil
        finalStandId = nil
        finalEntryId = nil
        finalPlus24StandId = standId
        finalPlus24EntryId = entryId
        text = initialText
        if !showOverlay {
            showOverlay = true
        }
    }
    
//    func showWorkstreamAddPlan(_ id: Workstream.ID, standId: Standup.ID?) {
//        if workstreamAddPlanId == id {
//            close()
//            return
//        }
//        workstreamAddUpdateId = nil
//        workstreamAddUpdateStandId = nil
//        workstreamAddPlanId = id
//        workstreamAddPlanStandId = standId
//        if !showOverlay {
//            showOverlay = true
//        }
//    }
}


struct WorkspaceQuickInputOverlay: View {
    @Environment(WorkspaceOverlayViewModel.self) private var ovm
    
    let onSubmit: () -> Void
    
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
    
    var body: some View {
        @Bindable var ovm = ovm
        VStack(spacing: 8) {
            HStack {
                if ovm.finalPlus24EntryId != nil {
                    Text("Final (+24)")
                } else if ovm.finalEntryId != nil {
                    Text("Final")
                } else if ovm.draftNotesEntryId != nil || ovm.draftNotesPlus24EntryId != nil {
                    Text("Draft notes")
                } else if let id = ovm.workstreamAddUpdateId {
                    Text("Adding update to workstream: \(id)")
                }
                Spacer()
            }
            GrowingTextView2UI(
                text: $ovm.text,
                placeholder: overlayPlaceholder
            ) {
                onSubmit()
            }
            HStack {
                Button("Cancel") {
                    ovm.close()
                }
                Spacer()
                if isSaveMode {
                    Button("Save") {
                        onSubmit()
                    }
                    .keyboardShortcut(.defaultAction)
                } else if let id = ovm.workstreamAddUpdateId {
                    Button("Add") {
                        onSubmit()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(
                        ovm.text.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
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
        .onAppear {
            focus = true
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var ovm = WorkspaceOverlayViewModel()
        @FocusState private var focused: Bool

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Color.clear
                    .frame(width: 600, height: 400)
                WorkspaceQuickInputOverlay(
                    onSubmit: {
                        ovm.close()
                    }
                )
            }
            .environment(ovm)
            .onAppear {
                ovm.showWorkstreamAddUpdate(Workstream.ID())
                focused = true
            }
        }
    }

    return PreviewWrapper()
}
