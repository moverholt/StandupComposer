//
//  SettingsWindowContentView.swift
//  FEJournal
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct SettingsWindowContentView: View {
    @Environment(UserSettings.self) var settings: UserSettings
    @State private var models: [String] = []
    @State private var modelsLoading = true
    @State private var modelsError: String? = nil
    @State private var modelsRetryId = 0
    @State private var jiraTestLoading = false
    @State private var jiraTestMessage: String? = nil
    @State private var jiraTestSuccess: Bool? = nil

    var body: some View {
        Form {
            Section("OpenAI") {
                TextField(
                    "API Key",
                    text: Binding(
                        get: { settings.openAIApiKey ?? "" },
                        set: {
                            if $0.isEmpty {
                                settings.openAIApiKey = nil
                            } else {
                                settings.openAIApiKey = $0
                            }
                        }
                    )
                )
                TextField(
                    "API Host",
                    text: Binding(
                        get: { settings.openAIApiUrl },
                        set: {
                            if $0.isEmpty {
                                settings.openAIApiUrl = UserSettings.defaultOpenAIHost
                            } else {
                                settings.openAIApiUrl = $0
                            }
                        }
                    )
                )
                if modelsLoading {
                    HStack {
                        Text("Model")
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading…")
                            .foregroundStyle(.secondary)
                    }
                } else if let modelsError {
                    HStack {
                        Text("Model")
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(modelsError)
                                .foregroundStyle(.red)
                                .lineLimit(2)
                            Button("Try Again") { modelsRetryId += 1 }
                                .buttonStyle(.borderless)
                        }
                    }
                } else {
                    Picker("Model", selection: Binding(
                        get: { settings.openAISelectedModel },
                        set: { settings.openAISelectedModel = $0 }
                    )) {
                        ForEach(models, id: \.self) { model in
                            Text(model)
                        }
                    }
                }
            }
            Section("Jira") {
                TextField(
                    "URL",
                    text: Binding(
                        get: { settings.jiraUrl },
                        set: { settings.jiraUrl = $0 }
                    )
                )
                TextField(
                    "Access Token",
                    text: Binding(
                        get: { settings.jiraAccessToken ?? "" },
                        set: {
                            if $0.isEmpty {
                                settings.jiraAccessToken = nil
                            } else {
                                settings.jiraAccessToken = $0
                            }
                        }
                    )
                )
                HStack {
                    Button("Test Connection") {
                        Task { @MainActor in
                            jiraTestLoading = true
                            jiraTestMessage = nil
                            jiraTestSuccess = nil
                            do {
                                let name = try await testJiraConnection(url: settings.jiraUrl, token: settings.jiraAccessToken ?? "")
                                jiraTestSuccess = true
                                jiraTestMessage = "Connected as \(name)"
                            } catch {
                                jiraTestSuccess = false
                                jiraTestMessage = error.localizedDescription
                            }
                            jiraTestLoading = false
                        }
                    }
                    .disabled(jiraTestLoading || settings.jiraUrl.trimmingCharacters(in: .whitespaces).isEmpty || (settings.jiraAccessToken ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
                    Spacer()
                    if jiraTestLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Testing…")
                            .foregroundStyle(.secondary)
                    } else if let msg = jiraTestMessage {
                        Text(msg)
                            .foregroundStyle(jiraTestSuccess == true ? .green : .red)
                            .lineLimit(2)
                    }
                }
            }
        }
        .task(id: modelsRetryId) {
            modelsLoading = true
            modelsError = nil
            do {
                models = try await fetchOpenAIModels()
            } catch {
                modelsError = error.localizedDescription
                models = []
            }
            modelsLoading = false
        }
        .frame(
            minWidth: 400,
            maxWidth: 800
        )
    }
}

#Preview {
    SettingsWindowContentView()
}
