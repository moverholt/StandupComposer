//
//  UpdateGeneratorView.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import SwiftUI

struct UpdateGeneratorView: View {
    @Binding var update: Standup.WorkstreamUpdate
    @Binding var ws: Workstream
    
    var prompt: String {
        wsUpdatePrompt(ws.updates)
    }
    
    private func run() async {
        update.ai.final = nil
        update.ai.partial = nil
        update.ai.error = nil
        update.ai.active = true
        let stream = streamOpenAIChat(prompt: prompt)
        do {
            for try await partial in stream {
                update.ai.partial = partial
            }
            update.ai.final = update.ai.partial
            update.body = update.ai.final
            update.ai.partial = nil
        } catch {
            update.ai.error = error.localizedDescription
        }
        update.ai.active = false
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            VStack(alignment: .leading, spacing: 0) {
                if let err = update.ai.error {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(err)
                            .foregroundStyle(.red)
                        Button("Try Again") {
                            Task {
                                await run()
                            }
                        }
                    }
                } else if let final = update.ai.final {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(final)
                        Button("Regenerate") {
                            Task {
                                await run()
                            }
                        }
                    }
                } else if update.ai.active {
                    HStack(alignment: .top) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                        Text(update.ai.partial ?? "")
                    }
                } else {
                    Button("Run") {
                        Task {
                            await run()
                        }
                    }
                }
                Spacer()
            }
            .textSelection(.enabled)
        }
    }
}

#Preview {
    @Previewable @State var ws = Workstream()
    @Previewable @State var standUpdate = Standup.WorkstreamUpdate(Workstream())
    UpdateGeneratorView(update: $standUpdate, ws: $ws)
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .padding()
}
