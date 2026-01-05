//
//  WorkspaceStandupDetailView.swift
//  StandupComposer
//
//  Created by Assistant on 12/27/25.
//

import SwiftUI


struct WorkspaceStandupDetailView: View {
    @Binding var stand: Standup
    @Binding var streams: [Workstream]
    
    private func runAll() {
        Task {
            for stream in streams.active {
                print("Run stream: \(stream.title)")
                if let index = stand.updates.findIndex(wsid: stream.id) {
                    Task {
                        await run(index, updates: stream.updates)
                    }
                }
            }
        }
    }
    
    @MainActor
    private func run(_ index: Int, updates: [Workstream.Update]) async {
        stand.updates[index].ai.final = nil
        stand.updates[index].ai.partial = nil
        stand.updates[index].ai.error = nil
        stand.updates[index].ai.active = true
        let stream = streamOpenAIChat(prompt: wsUpdatePrompt(updates))
        do {
            for try await partial in stream {
                stand.updates[index].ai.partial = partial
            }
            stand.updates[index].ai.final = stand.updates[index].ai.partial
            stand.updates[index].body = stand.updates[index].ai.final
            stand.updates[index].ai.partial = nil
        } catch {
            stand.updates[index].ai.error = error.localizedDescription
        }
        stand.updates[index].ai.active = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(stand.title)
                    .font(.title)
                    .padding(.bottom)
                Spacer()
                HStack {
                    Button(action: runAll) {
                        Label("Generate Standup", systemImage: "brain")
                    }
                }
                .controlSize(.regular)
                .buttonStyle(.bordered)
            }
            if streams.active.isEmpty {
                Text("No active workstreams.")
                    .font(.headline)
            } else {
                TabView {
                    Tab("Edit", systemImage: "pencil") {
                        EditStandScrollView(stand: $stand, streams: $streams)
                    }
                    Tab("Formatted", systemImage: "paragraphsign") {
                        StandFormattedView(stand: stand)
                    }
                }
            }
            Spacer()
        }
        .scenePadding()
    }
}

#Preview {
    @Previewable @State var stand = Standup(.tomorrow)
    @Previewable @State var streams: [Workstream] = []
    WorkspaceStandupDetailView(stand: $stand, streams: $streams)
        .frame(width: 700, height: 400)
        .onAppear {
            var ws1 = Workstream()
            ws1.title = "Add new pasta types to pasta menu"
            ws1.issueKey = "FOOD-1234"
            ws1.appendUpdate(
                .today,
                body: "Met with project owner to discuss requirements."
            )
            ws1.appendUpdate(
                .today,
                body: "Wrote JIRA story."
            )
            streams.append(ws1)
            var ws2 = Workstream()
            ws2.title = "Add new sparkling water flavors"
            ws2.issueKey = "FOOD-1000"
            streams.append(ws2)
        }
}

