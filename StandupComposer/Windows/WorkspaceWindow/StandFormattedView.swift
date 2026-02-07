//
//  StandFormattedView.swift
//  StandupComposer
//
//  Created by Developer on 2025-12-29.
//

import SwiftUI

struct StandFormattedView: View {
    @Environment(UserSettings.self) var settings
    let stand: Standup
    @Binding var space: Workspace

    @State private var partial: String?
    @State private var loading = false
    @State private var error: String?
    @State private var selectAllRequested = false

    @MainActor
    private func run() async {
        loading = true
        error = nil
        partial = ""
        let prompt = slackFormatterPrompt(
            stand.id,
            space: space,
            jiraBaseUrl: settings.jiraUrl
        )
        let stream = streamOpenAIChat(
            prompt: prompt,
            config: OpenAIConfig(settings)
        )
        do {
            for try await partial in stream {
                self.partial = partial
            }
            if let formatted = self.partial {
                space.setFormatted(standId: stand.id, formatted: formatted)
            }
        } catch {
            self.error = error.localizedDescription
        }
        partial = nil
        loading = false
    }

    private var hasContent: Bool {
        partial != nil || stand.formattedSlack != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 0)
                if loading {
                    ProgressView()
                        .scaleEffect(0.85)
                }
                Button {
                    Task { await run() }
                } label: {
                    Label("Generate for Slack", systemImage: "sparkles")
                }
                .disabled(loading || !stand.hasContentToFormat)
                if hasContent {
                    Button(action: { selectAllRequested = true }) {
                        Label("Select All", systemImage: "doc.on.doc")
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    if hasContent, let body = partial ?? stand.formattedSlack {
                        SelectableFormattedTextView(
                            content: body,
                            selectAllRequested: $selectAllRequested
                        )
                        .frame(minHeight: 400, maxHeight: .infinity)
                    } else if !stand.hasContentToFormat {
                        noContentToFormatState
                    } else if !loading {
                        emptyState
                    }
                }
                .padding()
            }
        }
    }

    private var noContentToFormatState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.secondary)
            VStack(spacing: 4) {
                Text("Nothing to Format Yet")
                    .font(.title2.weight(.semibold))
                Text("Add workstream entries with Yesterday or Today drafts to this standup, then you can generate a Slack-ready summary.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.vertical, 24)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.bubble")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.secondary)
            VStack(spacing: 4) {
                Text("No Formatted Slack Yet")
                    .font(.title2.weight(.semibold))
                Text("Generate a Slack-ready summary from your standup.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 280)
            Button {
                Task { await run() }
            } label: {
                Label("Generate for Slack", systemImage: "sparkles")
            }
            .buttonStyle(.borderedProminent)
            .disabled(loading)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.vertical, 24)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stand = space.stands.last {
            StandFormattedView(stand: stand, space: $space)
                .padding()
                .frame(width: 400, height: 300)
                .environment(UserSettings())
        }
    }
    .onAppear {
        let ws1 = space.createWorkstream("Add Taco Bar to Menu")
        space.addWorkstreamEntry(ws1, "I talked to manager about requirements.")
        let s1 = space.createStandup("Standup 1")
    }
}
