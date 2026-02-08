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
            SubmittableTextView(
                text: $text,
                placeholder: "What did you do?",
                maxLines: 3
            ) {
                submit()
            }
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(.quaternary.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(.separator, lineWidth: 0.5)
            )
            HStack {
                Spacer()
                Button {
                    submit()
                } label: {
                    Label("Add", systemImage: "paperplane.fill")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
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
