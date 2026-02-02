import SwiftUI

struct AddWorkstreamUpdateButton: View {
    @Binding var space: Workspace
    let workstreamId: Workstream.ID

    @State private var isPopoverPresented = false
    @State private var draftText = ""

    private var trimmed: String {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmed.isEmpty else { return }
        space.addWorkstreamEntry(workstreamId, trimmed)
        draftText = ""
        isPopoverPresented = false
    }

    var body: some View {
        Button {
            isPopoverPresented = true
        } label: {
            Label("Add update", systemImage: "plus.circle")
        }
        .buttonStyle(.plain)
        .controlSize(.small)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 6) {
                TextField("What did you do?", text: $draftText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3, reservesSpace: true)
                    .onSubmit { submit() }
                Button {
                    submit()
                } label: {
                    Label("Add", systemImage: "paperplane.fill") .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .disabled(trimmed.isEmpty)
            }
            .padding()
            .frame(minWidth: 220, minHeight: 100)
            .onDisappear {
                draftText = ""
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stream = space.streams.first {
            AddWorkstreamUpdateButton(space: $space, workstreamId: stream.id)
        }
    }
    .padding()
    .frame(width: 300, height: 120)
    .onAppear {
        let _ = space.createWorkstream("Preview Workstream", "PREV-1")
    }
}
