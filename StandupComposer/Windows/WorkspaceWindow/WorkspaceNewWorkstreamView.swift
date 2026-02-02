//
//  WorkspaceNewWorkstreamView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceNewWorkstreamView: View {
    @Environment(UserSettings.self) var settings
    @Binding var space: Workspace
    @State private var title = "New Workstream"
    @State private var issueKey = ""
    @State private var jiraStories: [JiraStory] = []
    @State private var jiraLoading = false
    @State private var jiraError: String? = nil
    @State private var jiraRetryId = 0

    private var jiraConfigured: Bool {
        !settings.jiraUrl.trimmingCharacters(in: .whitespaces).isEmpty
            && !(settings.jiraAccessToken ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var createDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func handleSubmit() {
        let t = title.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return }
        let key = issueKey.trimmingCharacters(in: .whitespaces)
        var id = space.createWorkstream(title, issueKey)
        settings.workspaceSelected = .workstream(id)
    }

    private func fillFromJiraStory(_ story: JiraStory) {
        title = story.summary
        issueKey = story.key
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("New Workstream")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(
                        "Create a workstream to track plans and daily updates for a feature or project."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Create Workstream") {
                    handleSubmit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(createDisabled)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            Divider()

            Form {
                Section {
                    TextField("Title", text: $title)
                        .onSubmit { handleSubmit() }
                    TextField("Issue Key", text: $issueKey, prompt: Text("e.g. PROJ-123"))
                        .onSubmit { handleSubmit() }
                } header: {
                    Text("Details")
                } footer: {
                    Text(
                        "Give the workstream a name. Optionally add a Jira issue key to link it to a ticket; you can also pick one from your assigned stories below."
                    )
                }

                Section {
                    if !jiraConfigured {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(
                                "Jira is not configured. Set the Jira URL and Access Token in Settings to see stories assigned to you and prefill the form."
                            )
                            .foregroundStyle(.secondary)
                            Button("Open Settings…") {
                                NSApp.sendAction(
                                    Selector(("showSettings:")), to: NSApp.delegate, from: nil)
                            }
                            .buttonStyle(.borderless)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    } else if jiraLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.85)
                            Text("Loading your Jira stories…")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                    } else if let err = jiraError {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(err)
                                .foregroundStyle(.red)
                                .lineLimit(4)
                            Button("Try Again") { jiraRetryId += 1 }
                                .buttonStyle(.borderless)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    } else if jiraStories.isEmpty {
                        Text("No stories assigned to you in Jira.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    } else {
                        JiraStoryPickerList(
                            stories: jiraStories,
                            onSelect: fillFromJiraStory
                        )
                        .frame(minHeight: 240)
                    }
                } header: {
                    HStack {
                        Text("Stories Assigned to You")
                        Spacer()
                        if jiraConfigured {
                            Button {
                                jiraRetryId += 1
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .buttonStyle(.borderless)
                            .disabled(jiraLoading)
                            .help("Refresh stories")
                        }
                    }
                } footer: {
                    if jiraConfigured && !jiraStories.isEmpty {
                        Text("Select a story to fill in the title and issue key above.")
                    } else if jiraConfigured {
                        Text(
                            "Stories from your Jira instance. Tapping one copies its title and key into the form."
                        )
                    } else {
                        Text(
                            "Configure Jira in Settings to link workstreams to tickets and prefill from your assigned stories."
                        )
                    }
                }
                .task(id: jiraRetryId) {
                    guard jiraConfigured else { return }
                    jiraLoading = true
                    jiraError = nil
                    do {
                        jiraStories = try await fetchJiraStoriesAssignedToMe(
                            url: settings.jiraUrl,
                            token: settings.jiraAccessToken ?? ""
                        )
                    } catch {
                        jiraError = error.localizedDescription
                        jiraStories = []
                    }
                    jiraLoading = false
                }
            }
            .formStyle(.grouped)
        }
    }
}

private struct JiraStoryPickerList: View {
    let stories: [JiraStory]
    let onSelect: (JiraStory) -> Void

    var body: some View {
        List {
            ForEach(stories) { story in
                Button {
                    onSelect(story)
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("[\(story.key)] \(story.summary)")
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.primary)
                        }
                        Spacer(minLength: 8)
                        Label("Use", systemImage: "plus.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.accentColor)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Use this story to fill in the title and issue key")
            }
        }
        .listStyle(.inset)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    WorkspaceNewWorkstreamView(space: $space)
        .environment(UserSettings.shared)
        .frame(width: 420, height: 560)
}
