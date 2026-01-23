import SwiftUI

public struct WorkstreamUpdatesScrollView: View {
    let space: Workspace
    @Binding var stream: Workstream
    
    private var last60Days: [IsoDay] {
        (0..<60).map({ IsoDay.today.subDays($0) }).reversed()
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if stream.updatesByDay.count == 0 {
                    Text("None")
                } else {
                    ForEach(last60Days) { day in
                        if let updates = stream.updatesByDay[day] {
                            Text(day.formatted(style: .abbreviated))
                                .foregroundStyle(.secondary)
                                .font(.title3)
                            WorkstreamUpdatesDay(
                                updates: updates,
                                space: space,
                                stream: $stream
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var stream = Workstream()
    WorkstreamUpdatesScrollView(
        space: Workspace(),
        stream: $stream
    )
}
