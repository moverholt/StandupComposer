//
//  WorkspaceStandupDetailView.swift
//  StandupComposer
//
//  Created by Assistant on 12/27/25.
//

import SwiftUI


struct WorkspaceStandupDetailView: View {
    @Binding var stand: Standup
    @Binding var workspace: Workspace
    
    private func runAll() {
        Task {
            for upd in stand.prevDay {
                if let ws = workspace.streams.find(id: upd.ws.id) {
                    if let index = stand.prevDay.findIndex(wsid: ws.id) {
                        Task {
                            await runUpdate(
                                index,
                                prompt: wsUpdatePrompt(ws, ws.updates.all),
                            )
                        }
                    }
                }
            }
        }
        Task {
            for pln in stand.today {
                if let ws = workspace.streams.find(id: pln.ws.id) {
                    if let index = stand.today.findIndex(wsid: ws.id) {
                        Task {
                            await runPlan(index, prompt: wsPlanPrompt(ws))
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func runUpdate(_ index: Int, prompt: String) async {
        stand.prevDay[index].ai.final = nil
        stand.prevDay[index].ai.partial = nil
        stand.prevDay[index].ai.error = nil
        stand.prevDay[index].ai.active = true
        let stream = streamOpenAIChat(prompt: prompt)
        do {
            for try await partial in stream {
                stand.prevDay[index].ai.partial = partial
            }
            stand.prevDay[index].ai.final = stand.prevDay[index].ai.partial
            stand.prevDay[index].body = stand.prevDay[index].ai.final
            stand.prevDay[index].ai.partial = nil
        } catch {
            stand.prevDay[index].ai.error = error.localizedDescription
        }
        stand.prevDay[index].ai.active = false
    }
    
    @MainActor
    private func runPlan(_ index: Int, prompt: String) async {
        stand.today[index].ai.final = nil
        stand.today[index].ai.partial = nil
        stand.today[index].ai.error = nil
        stand.today[index].ai.active = true
        let stream = streamOpenAIChat(prompt: prompt)
        do {
            for try await partial in stream {
                stand.today[index].ai.partial = partial
            }
            stand.today[index].ai.final = stand.today[index].ai.partial
            stand.today[index].body = stand.today[index].ai.final
            stand.today[index].ai.partial = nil
        } catch {
            stand.today[index].ai.error = error.localizedDescription
        }
        stand.today[index].ai.active = false
    }
    
    private var title: String {
        if stand.editing {
            return "Editing: \(stand.title)"
        }
        return stand.title
    }
    
    private func publish() {
        workspace.publish(standId: stand.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.title)
                    .padding(.bottom)
                Spacer()
                if stand.editing {
                    HStack {
                        Button(action: runAll) {
                            Label(
                                "Generate all summaries",
                                systemImage: "sparkles.rectangle.stack"
                            )
                        }
                        Button(action: publish) {
                            Label(
                                "Publish standup",
                                systemImage: "checkmark.seal"
                            )
                        }
                    }
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                }
            }
            if stand.editing {
                TabView {
                    Tab("Edit", systemImage: "pencil") {
                        EditStandScrollView(
                            stand: $stand,
                            workspace: $workspace
                        )
                    }
                    Tab("Formatted", systemImage: "paragraphsign") {
                        StandFormattedView(stand: stand)
                    }
                }
            } else {
                StandFormattedView(stand: stand)
            }
//            VStack(alignment: .leading) {
//                Text("Workstream update ids: \(stand.wsUpdates.count.formatted())")
//                Text(stand.wsUpdates.map(\.uuidString).joined(separator: ","))
//                    .foregroundStyle(.secondary)
//                Text("Workstream plan ids: \(stand.wsPlans.count.formatted())")
//            }
        }
    }
}

#Preview {
    @Previewable @State var workspace = Workspace()
    VStack {
        if workspace.stands.isEmpty {
            ProgressView()
        } else {
            WorkspaceStandupDetailView(
                stand: $workspace.stands[0],
                workspace: $workspace
            )
        }
    }
    .frame(width: 700, height: 400)
    .onAppear {
        var ws1 = Workstream()
        ws1.title = "Add new pasta types to pasta menu"
        ws1.issueKey = "FOOD-1234"
        ws1.appendUpdate(
            .today,
            body: "Met with project owner to discuss requirements."
        )
        ws1.appendUpdate(.today, body: "Wrote JIRA story.")
        workspace.streams.append(ws1)
        
        var ws2 = Workstream()
        ws2.title = "Add new sparkling water flavors"
        ws2.issueKey = "FOOD-1000"
        workspace.streams.append(ws2)
        
        var s1 = Standup(.today)
//        s1.addWorkstream(ws1)
//        s1.addWorkstream(ws2)
        
        s1.publish()
        workspace.stands.append(s1)
    }
}

