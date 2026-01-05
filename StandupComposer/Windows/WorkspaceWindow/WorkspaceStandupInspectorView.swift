import SwiftUI

struct WorkspaceStandupInspectorView: View {
    @Binding var stand: Standup

    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $stand.title)
                LabeledContent("Day", value: stand.day.formatted(style: .complete))
            }
            Section("Status") {
                Toggle("Deleted", isOn: $stand.deleted)
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

        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(.today)
    WorkspaceStandupInspectorView(stand: $stand)
        .frame(width: 200)
}
