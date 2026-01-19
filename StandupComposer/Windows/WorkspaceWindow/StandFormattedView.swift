//
//  StandFormattedView.swift
//  StandupComposer
//
//  Created by Developer on 2025-12-29.
//

import SwiftUI

struct StandFormattedView: View {
    @Environment(UserSettings.self) var settings
    @Binding var stand: Standup
    
    @State private var partial: String?
    @State private var loading = false
    @State private var error: String?
    
    @MainActor
    private func run() async {
        loading = true
        error = nil
        partial = ""
        let prompt = slackFormatterPrompt(stand)
        let stream = streamOpenAIChat(
            prompt: prompt,
            config: OpenAIConfig(settings)
        )
        do {
            for try await partial in stream {
                self.partial = partial
            }
            stand.formattedSlack = self.partial
        } catch {
            self.error = error.localizedDescription
        }
        partial = nil
        loading = false
    }

    var body: some View {
        ScrollView {
            VStack {
                if let body = partial ?? stand.formattedSlack {
                    Text(body)
                }
                Button(
                    action: {
                        Task {
                            await run()
                        }
                    }
                ) {
                    Label("Format", systemImage: "wand.and.stars")
                }
                .disabled(loading)
                if loading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .textSelection(.enabled)
        }
    }
}

#Preview {
    @Previewable @State var stand = Standup(.today)
    StandFormattedView(stand: $stand)
        .frame(width: 600, height: 400)
        .environment(UserSettings())
        .onAppear {
            var ws1 = Workstream()
            ws1.issueKey = "ZZZZ-9998"
            
            var up1 = Standup.WorkstreamGenUpdate(ws1)
            up1.body = "This is a test update."
            stand.prevDay.append(up1)
            
            var ws2 = Workstream()
            ws2.issueKey = "ZZZZ-9999"
            
            var up2 = Standup.WorkstreamGenUpdate(ws2)
            up2.body = "This is another test update."
            stand.prevDay.append(up2)
            
            
            var pl1 = Standup.WorkstreamGenUpdate(ws1)
            pl1.body = "This is a plan."
            stand.today.append(pl1)
            
            var pl2 = Standup.WorkstreamGenUpdate(ws2)
            pl2.body = "This is another test plan."
            stand.today.append(pl2)
        }
}
