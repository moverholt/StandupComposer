import Observation

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
}
