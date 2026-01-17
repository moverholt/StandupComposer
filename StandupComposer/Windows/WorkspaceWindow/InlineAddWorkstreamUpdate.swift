import SwiftUI

struct InlineAddWorkstreamUpdate: View {
    @Binding var stream: Workstream
    @State private var draft: String = ""

    private var trimmed: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var canSubmit: Bool { !trimmed.isEmpty }

    var body: some View {
        HStack(spacing: 8) {
            TextField("Add an update...", text: $draft)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    addDraft()
                }
            Button {
                addDraft()
            } label: {
                Label("Add", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSubmit)
        }
    }

    private func addDraft() {
        let text = trimmed
        guard !text.isEmpty else { return }
        stream.appendUpdate(.today, body: text)
        draft = ""
    }
}

#Preview {
    @Previewable @State var ws = Workstream()
    InlineAddWorkstreamUpdate(stream: $ws)
        .padding()
}
