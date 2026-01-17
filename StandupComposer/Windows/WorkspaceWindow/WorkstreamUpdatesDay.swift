import SwiftUI

struct WorkstreamUpdatesDay: View {
    let updates: [Workstream.Update]
    @Binding var stream: Workstream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Updates")
                .font(.title2)
                .foregroundStyle(.secondary)
            VStack {
                ForEach(updates) { upd in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(upd.body)
                                .textSelection(.enabled)
                            Spacer()
                            Menu {
                                Button(role: .destructive) {
                                    stream.deleteUpdate(upd)
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
                        if let standId = upd.standId {
                            Text("Standup ID: \(standId)")
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
    }
}

#Preview {
    @Previewable @State var stream = Workstream()
    let day = IsoDay.today

    return WorkstreamUpdatesDay(
        updates: stream.updatesByDay[.today] ?? [],
        stream: $stream
    )
    .scenePadding()
    .onAppear {
        if stream.updates.isEmpty {
            stream.appendUpdate(.today, body: "This is an update")
            stream.appendUpdate(.today, body: "Another update for today")
        }
    }
}
