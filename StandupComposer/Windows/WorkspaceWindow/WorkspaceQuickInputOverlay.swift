import SwiftUI

@Observable
class WorkspaceOverlayViewModel {
    var showOverlay = false
    var text: String = ""
    
    var workstreamAddUpdateId: Workstream.ID?
    var workstreamAddUpdateStandId: Standup.ID?
    
    var workstreamAddPlanId: Workstream.ID?
    var workstreamAddPlanStandId: Standup.ID?
    
    func close() {
        showOverlay = false
        text = ""
        
        workstreamAddUpdateId = nil
        workstreamAddUpdateStandId = nil
        
        workstreamAddPlanId = nil
        workstreamAddPlanStandId = nil
    }
    
    func showWorkstreamAddUpdate(_ id: Workstream.ID, standId: Standup.ID?) {
        if workstreamAddUpdateId == id {
            close()
            return
        }
        workstreamAddPlanId = nil
        workstreamAddPlanStandId = nil
        workstreamAddUpdateId = id
        workstreamAddUpdateStandId = standId
        if !showOverlay {
            showOverlay = true
        }
    }
    
    func showWorkstreamAddPlan(_ id: Workstream.ID, standId: Standup.ID?) {
        if workstreamAddPlanId == id {
            close()
            return
        }
        workstreamAddUpdateId = nil
        workstreamAddUpdateStandId = nil
        workstreamAddPlanId = id
        workstreamAddPlanStandId = standId
        if !showOverlay {
            showOverlay = true
        }
    }
}


struct WorkspaceQuickInputOverlay: View {
    @Environment(WorkspaceOverlayViewModel.self) private var ovm
    
    let onSubmit: () -> Void
    
    @FocusState private var focus: Bool
    
    var body: some View {
        @Bindable var ovm = ovm
        VStack(spacing: 8) {
            HStack {
                if let id = ovm.workstreamAddUpdateId {
                    Text("Adding update to workstream: \(id)")
                }
                if let id = ovm.workstreamAddPlanId {
                    Text("Adding plan to workstream: \(id)")
                }
                Spacer()
            }
            GrowingTextView2UI(
                text: $ovm.text,
                placeholder: "Type something here"
            ) {
                onSubmit()
            }
            HStack {
                Button("Cancel") {
                    ovm.close()
                }
                Spacer()
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
                ovm.showWorkstreamAddUpdate(Workstream.ID(), standId: nil)
                focused = true
            }
        }
    }

    return PreviewWrapper()
}
