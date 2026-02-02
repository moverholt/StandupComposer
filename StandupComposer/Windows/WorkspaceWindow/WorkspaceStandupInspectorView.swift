import SwiftUI

struct WorkspaceStandupInspectorView: View {
    @Environment(UserSettings.self) var settings
    @Binding var space: Workspace
    let stand: Standup

    @State private var showConfirm = false
    
    private var standBinding: Binding<Standup> {
        Binding(
            get: { stand },
            set: { space.updateStandup($0) }
        )
    }

    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: standBinding.title)
            }
            Section("About") {
                LabeledContent("Status", value: stand.status.description)
                LabeledContent("ID") {
                    Text(stand.id.uuidString)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
                .help(stand.id.uuidString)
                LabeledContent("Range Start", value: stand.rangeStart.formatted())
                LabeledContent("Range End", value: stand.rangeEnd?.formatted() ?? "—")
                if let prevId = stand.previousStandupId ?? stand.previousStandId {
                    LabeledContent("Previous Stand") {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(space.getStand(prevId)?.title ?? "Unknown")
                            Text(prevId.uuidString)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .textSelection(.enabled)
                        }
                    }
                    .help(prevId.uuidString)
                } else {
                    LabeledContent("Previous Stand", value: "—")
                }
                LabeledContent("Created", value: stand.created.formatted())
                LabeledContent("Updated", value: stand.updated.formatted())
            }
            Section {
                Button(role: .destructive) {
                    showConfirm = true
                } label: {
                    Label("Delete Standup", systemImage: "trash")
                }
                .buttonStyle(.borderless)
            }
            .confirmationDialog(
                "Delete Standup?",
                isPresented: $showConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    space.deleteStand(stand.id)
                    settings.workspaceSelected = .none
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stand = space.stands.first {
            WorkspaceStandupInspectorView(space: $space, stand: stand)
        }
    }
    .environment(UserSettings())
    .padding()
    .frame(width: 300)
    .onAppear {
        let _ = space.createStandup("Preview standup")
    }
}
