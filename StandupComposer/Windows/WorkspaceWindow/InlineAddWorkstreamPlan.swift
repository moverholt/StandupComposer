import SwiftUI

struct InlineAddWorkstreamPlan: View {
    @Binding var stream: Workstream
    @State private var draft: String = ""

    private var trimmed: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var canSubmit: Bool { !trimmed.isEmpty }

    var body: some View {
        HStack(spacing: 8) {
            TextField("Add a plan...", text: $draft)
                .textFieldStyle(.roundedBorder)
                .onSubmit { addDraft() }
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
        stream.plans.append(.today, text)
        draft = ""
    }
}

#Preview {
    @Previewable @State var ws = Workstream()
    InlineAddWorkstreamPlan(stream: $ws)
        .padding()
}
