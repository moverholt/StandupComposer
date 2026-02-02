import SwiftUI

struct WorkstreamAddUpdateInput: View {
    @Binding var space: Workspace
    let stream: Workstream
    
    @State private var text = ""
    
    private func submit() {
        let trimmed = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard trimmed.isEmpty == false else { return }
        space.addWorkstreamEntry(stream.id, trimmed)
        text = ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Update")
                .font(.headline)
                .foregroundStyle(.secondary)
            HStack(alignment: .bottom, spacing: 8) {
                TextField(
                    "What did you do?",
                    text: $text,
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .lineLimit(3, reservesSpace: true)
                .onSubmit { submit() }
                Button {
                    submit()
                } label: {
                    Label("Add", systemImage: "paperplane.fill")
                        .labelStyle(.titleAndIcon)
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)
                .disabled(
                    text.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.separator, lineWidth: 1)
        )
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stream = space.streams.first {
            WorkstreamAddUpdateInput(space: $space, stream: stream)
        }
    }
    .onAppear {
        let _ = space.createWorkstream("Test Workstream")
    }
}
