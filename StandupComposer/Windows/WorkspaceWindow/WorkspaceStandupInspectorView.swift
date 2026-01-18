import SwiftUI

struct WorkspaceStandupInspectorView: View {
    @Environment(UserSettings.self) var settings
    @Binding var stand: Standup
    @Binding var space: Workspace
    
    @State private var showConfirm = false

    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $stand.title)
                LabeledContent("Day", value: stand.day.formatted(style: .complete))
            }
            Section(
                header: Text("")
            ) {
                HStack {
                    Text("Created")
                    Spacer()
                    Text(stand.created.formatted())
                }
                HStack {
                    Text("Updated")
                    Spacer()
                    Text(stand.updated.formatted())
                }
            }
            Button(role: .destructive) {
                showConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .confirmationDialog(
                "Are you sure you want to delete this?",
                isPresented: $showConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    space.deleteStand(stand.id)
                    settings.workspaceSelected = .none
                }
                Button("Cancel", role: .cancel) {
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(.today)
    @Previewable @State var space = Workspace()
    WorkspaceStandupInspectorView(stand: $stand, space: $space)
        .frame(width: 200)
}
