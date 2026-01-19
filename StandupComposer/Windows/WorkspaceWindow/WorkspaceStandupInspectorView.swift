import SwiftUI

struct WorkspaceStandupInspectorView: View {
    @Environment(UserSettings.self) var settings
    @Binding var stand: Standup
    @Binding var space: Workspace

    @State private var showConfirm = false

    var body: some View {
        Form {
            Section("General") {
                TextField("Title", text: $stand.title)
                LabeledContent("Day", value: stand.day.formatted(style: .complete))
            }
            Section("About") {
                LabeledContent("ID") {
                    Text(stand.id.uuidString)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
                .help(stand.id.uuidString)
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
            .confirmationDialog("Delete Standup?", isPresented: $showConfirm, titleVisibility: .visible) {
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
    @Previewable @State var stand = Standup(.today)
    @Previewable @State var space = Workspace()
    WorkspaceStandupInspectorView(stand: $stand, space: $space)
        .environment(UserSettings())
        .padding()
        .frame(width: 300)
}
