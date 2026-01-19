//
//  UpdateGeneratorView.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import SwiftUI

struct UpdateGeneratorView: View {
    @Environment(UserSettings.self) var settings
    @Binding var update: Standup.WorkstreamGenUpdate
    
    let prompt: String
    
    private func run() async {
        update.ai.final = nil
        update.ai.partial = nil
        update.ai.error = nil
        update.ai.active = true
        let stream = streamOpenAIChat(
            prompt: prompt,
            config: OpenAIConfig(settings)
        )
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
        ZStack(alignment: .center) {
            Color.clear
            if let err = update.ai.error {
                VStack(alignment: .leading, spacing: 6) {
                    Text(err)
                        .foregroundStyle(.red)
                    Button(
                        action: {
                            Task {
                                await run()
                            }
                        }
                    ) {
                        Label("Try Again", systemImage: "arrow.clockwise")
                    }
                }
            } else if let final = update.ai.final {
                VStack(alignment: .leading, spacing: 6) {
                    Text(final)
                    Spacer()
                    Button(
                        action: {
                            Task {
                                await run()
                            }
                        }
                    ) {
                        Label("Refresh summary", systemImage: "arrow.clockwise")
                    }
                    .controlSize(.small)
                    .buttonStyle(.borderless)
                }
            } else if update.ai.active {
                VStack(alignment: .leading) {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                        Spacer()
                    }
                    Text(update.ai.partial ?? "")
                    Spacer()
                }
            } else {
                Button(
                    action: {
                        Task {
                            await run()
                        }
                    }
                ) {
                    Label("Generate", systemImage: "sparkles")
                }
            }
        }
        .textSelection(.enabled)
    }
}

#Preview {
    @Previewable @State var ws = Workstream()
    @Previewable @State var su = Standup.WorkstreamGenUpdate(Workstream())
    UpdateGeneratorView(
        update: $su,
        prompt: wsUpdatePrompt(ws, [], ws.updates)
    )
    .padding()
    .environment(UserSettings())
    .background(
        .thinMaterial,
        in: RoundedRectangle(cornerRadius: 12)
    )
    .padding()
}
