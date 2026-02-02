import SwiftUI

public struct WorkstreamUpdatesScrollView: View {
    @Binding var space: Workspace
    let stream: Workstream

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if stream.entries.count == 0 {
                    Text("None")
                } else {
                    ForEach(stream.entries) { entry in
                        WorkstreamEntry(space: $space, entry: entry)
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
    .onAppear {
        let wsId = space.createWorkstream("Preview Stream", "PREV-1")
        space.addWorkstreamEntry(wsId, "This is a workstream update")
    }
}
