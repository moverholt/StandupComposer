import SwiftUI

struct DayUpdates: View {
    let updates: [Workstream.Update]

    var body: some View {
        GroupBox(
            label: Label("Updates", systemImage: "pencil")
        ) {
            if updates.isEmpty {
                Text("No updates")
                    .font(.body)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(updates) { upd in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(.tertiary)
                        Text(upd.body)
                            .font(.title3)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                }
            }
        }
        .textSelection(.enabled)
    }
}

#Preview {
    DayUpdates(updates: [])
        .frame(width: 300, height: 400)
}
