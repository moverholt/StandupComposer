import SwiftUI

struct WorkstreamEntry: View {
    @Binding var space: Workspace
    let entry: Workstream.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                HStack {
                    Text(entry.body)
                        .textSelection(.enabled)
                    Spacer()
                    Menu {
                        Button(role: .destructive) {
                            space.deleteWorkstreamEntry(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .imageScale(.medium)
                            .padding(6)
                            .contentShape(Rectangle())
                    }
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
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stream = space.streams.first {
            if let entry = stream.entries.first {
                WorkstreamEntry(space: $space, entry: entry)
            }
        }
    }
    .onAppear {
    }
}
