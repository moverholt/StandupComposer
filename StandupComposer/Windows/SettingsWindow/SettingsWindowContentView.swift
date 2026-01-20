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
    @State private var openAITestLoading = false
    @State private var openAITestMessage: String? = nil
    @State private var openAITestSuccess: Bool? = nil

    var body: some View {
        Form {
            Section {
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
                    ))
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
                    ))
                if modelsLoading {
                    HStack(spacing: 8) {
                        Text("Model")
                        Spacer()
                        ProgressView()
                            .controlSize(.small)
                        Text("Loading…")
                            .foregroundStyle(.secondary)
                    }
                } else if modelsError != nil {
                    TextField(
                        "Model",
                        text: Binding(
                            get: { settings.openAISelectedModel },
                            set: { settings.openAISelectedModel = $0 }
                        ))
                } else {
                    Picker(
                        "Model",
                        selection: Binding(
                            get: { settings.openAISelectedModel },
                            set: { settings.openAISelectedModel = $0 }
                        )
                    ) {
                        ForEach(models, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
                if let err = modelsError {
                    HStack(alignment: .top, spacing: 8) {
                        Text(err)
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Button("Try Again") { modelsRetryId += 1 }
                            .buttonStyle(.borderless)
                    }
                }
                Button("Test Connection") {
                    Task { @MainActor in
                        openAITestLoading = true
                        openAITestMessage = nil
                        openAITestSuccess = nil
                        do {
                            let msg = try await testOpenAIConnection(
                                apiKey: settings.openAIApiKey ?? "", host: settings.openAIApiUrl)
                            openAITestSuccess = true
                            openAITestMessage = msg
                        } catch {
                            openAITestSuccess = false
                            openAITestMessage = error.localizedDescription
                        }
                        openAITestLoading = false
                    }
                }
                .disabled(
                    openAITestLoading
                        || (settings.openAIApiKey ?? "").trimmingCharacters(in: .whitespaces)
                            .isEmpty
                )
                if openAITestLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Testing…")
                            .foregroundStyle(.secondary)
                    }
                }
                if let msg = openAITestMessage {
                    Text(msg)
                        .foregroundStyle(openAITestSuccess == true ? .green : .red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } header: {
                Text("OpenAI")
            } footer: {
                Text("Your API key is stored locally and used only to reach the host above.")
            }
            Section {
                TextField(
                    "URL",
                    text: Binding(
                        get: { settings.jiraUrl },
                        set: { settings.jiraUrl = $0 }
                    ))
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
                    ))
                Button("Test Connection") {
                    Task { @MainActor in
                        jiraTestLoading = true
                        jiraTestMessage = nil
                        jiraTestSuccess = nil
                        do {
                            let name = try await testJiraConnection(
                                url: settings.jiraUrl, token: settings.jiraAccessToken ?? "")
                            jiraTestSuccess = true
                            jiraTestMessage = "Connected as \(name)"
                        } catch {
                            jiraTestSuccess = false
                            jiraTestMessage = error.localizedDescription
                        }
                        jiraTestLoading = false
                    }
                }
                .disabled(
                    jiraTestLoading || settings.jiraUrl.trimmingCharacters(in: .whitespaces).isEmpty
                        || (settings.jiraAccessToken ?? "").trimmingCharacters(in: .whitespaces)
                            .isEmpty
                )
                if jiraTestLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Testing…")
                            .foregroundStyle(.secondary)
                    }
                }
                if let msg = jiraTestMessage {
                    Text(msg)
                        .foregroundStyle(jiraTestSuccess == true ? .green : .red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } header: {
                Text("Jira")
            } footer: {
                Text("Jira URL and access token for fetching issues assigned to you.")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 480, minHeight: 420)
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
    }
}

#Preview {
    SettingsWindowContentView()
        .environment(UserSettings.shared)
}
