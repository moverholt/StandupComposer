//
//  WorkspaceStandupDetailView.swift
//  StandupComposer
//
//  Created by Assistant on 12/27/25.
//

import SwiftUI


struct WorkspaceStandupDetailView: View {
    @Environment(UserSettings.self) var settings
    
    @Binding var space: Workspace
    let stand: Standup

    private func runAll() {
//        Task {
//            for upd in stand.prevDay {
//                if let ws = workspace.streams.find(id: upd.ws.id) {
//                    if let index = stand.prevDay.findIndex(wsid: ws.id) {
//                        Task {
//                            await runUpdate(
//                                index,
//                                prompt: wsUpdatePrompt(
//                                    ws,
//                                    ws.plans.completedForStand(stand.id),
//                                    ws.updates.forStand(stand.id)
//                                ),
//                            )
//                        }
//                    }
//                }
//            }
//        }
//        Task {
//            for pln in stand.today {
//                if let ws = workspace.streams.find(id: pln.ws.id) {
//                    if let index = stand.today.findIndex(wsid: ws.id) {
//                        Task {
//                            await runPlan(
//                                index,
//                                prompt: wsPlanPrompt(
//                                    ws,
//                                    ws.plans.forStand(stand.id)
//                                )
//                            )
//                        }
//                    }
//                }
//            }
//        }
    }
    
    @MainActor
    private func runUpdate(_ index: Int, prompt: String) async {
//        stand.prevDay[index].ai.final = nil
//        stand.prevDay[index].ai.partial = nil
//        stand.prevDay[index].ai.error = nil
//        stand.prevDay[index].ai.active = true
//        let stream = streamOpenAIChat(
//            prompt: prompt,
//            config: OpenAIConfig(settings)
//        )
//        do {
//            for try await partial in stream {
//                stand.prevDay[index].ai.partial = partial
//            }
//            stand.prevDay[index].ai.final = stand.prevDay[index].ai.partial
//            stand.prevDay[index].body = stand.prevDay[index].ai.final
//            stand.prevDay[index].ai.partial = nil
//        } catch {
//            stand.prevDay[index].ai.error = error.localizedDescription
//        }
//        stand.prevDay[index].ai.active = false
    }
    
    @MainActor
    private func runPlan(_ index: Int, prompt: String) async {
//        stand.today[index].ai.final = nil
//        stand.today[index].ai.partial = nil
//        stand.today[index].ai.error = nil
//        stand.today[index].ai.active = true
//        let stream = streamOpenAIChat(
//            prompt: prompt,
//            config: OpenAIConfig(settings)
//        )
//        do {
//            for try await partial in stream {
//                stand.today[index].ai.partial = partial
//            }
//            stand.today[index].ai.final = stand.today[index].ai.partial
//            stand.today[index].body = stand.today[index].ai.final
//            stand.today[index].ai.partial = nil
//        } catch {
//            stand.today[index].ai.error = error.localizedDescription
//        }
//        stand.today[index].ai.active = false
    }
    
    private var title: String {
        if stand.editing {
            return "Editing: \(stand.title)"
        }
        return stand.title
    }
    
    private func publish() {
        space.publishStandup(stand.id)
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
                        EditStandScrollView(space: $space, stand: stand)
                    }
                    Tab("Formatted", systemImage: "paragraphsign") {
                        StandFormattedView(stand: stand)
                    }
                }
            } else {
                StandFormattedView(stand: stand)
            }
        }
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stand = space.stands.first {
            WorkspaceStandupDetailView(space: $space, stand: stand)
        }
    }
    .frame(width: 700, height: 400)
    .environment(UserSettings())
    .onAppear {
        let _ = space.createWorkstream("Workstream 1", "PREV-1")
        let _ = space.createWorkstream("Workstream 2", "PREV-2")
        let _ = space.createStandup("Preview Standup")
    }
}

