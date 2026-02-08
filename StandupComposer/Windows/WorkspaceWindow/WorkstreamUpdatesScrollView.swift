import SwiftUI

public struct WorkstreamUpdatesScrollView: View {
    @Binding var space: Workspace
    let stream: Workstream

    private var entriesByDay: [IsoDay: [Workstream.Entry]] {
        Dictionary(grouping: stream.entries, by: \.day)
    }

    private var sortedDays: [IsoDay] {
        entriesByDay.keys.sorted(by: <)
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if stream.entries.isEmpty {
                    Text("None")
                } else {
                    ForEach(sortedDays, id: \.self) { day in
                        let entries = entriesByDay[day] ?? []
                        Text(day.sectionHeaderTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, day == sortedDays.first ? 0 : 12)
                            .padding(.bottom, 4)
                        ForEach(entries) { entry in
                            WorkstreamEntry(space: $space, entry: entry)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stream = space.streams.first {
            WorkstreamUpdatesScrollView(space: $space, stream: stream)
        }
    }
    .frame(width: 400, height: 400)
    .padding()
    .onAppear {
        let wsId = space.createWorkstream("Preview Stream", "PREV-1")
        space.addWorkstreamEntry(wsId, "This is a workstream update")
        space.addWorkstreamEntry(
            wsId,
            "This is a workstream update on a different day"
        )

    }
}
