//
//  EditStandEntryCard.swift
//  StandupComposer
//

import SwiftUI

struct EditStandEntryCard: View {
    @Environment(UserSettings.self) var settings
    @Binding var space: Workspace
    let stand: Standup
    let entry: Standup.WorkstreamEntry
    let stream: Workstream

    private func jiraBrowseURL(issueKey: String) -> URL? {
        let base = settings.jiraUrl.trimmingCharacters(in: .whitespaces)
        guard !base.isEmpty else { return nil }
        let path = base.hasSuffix("/") ? String(base.dropLast()) : base
        return URL(string: "\(path)/browse/\(issueKey)")
    }

    private var viewedBinding: Binding<Bool> {
        Binding(
            get: { entry.reviewedAt != nil },
            set: { newValue in
                var s = space
                s.setEntryReviewed(
                    standId: stand.id,
                    entryId: entry.id,
                    reviewed: newValue
                )
                space = s
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(stream.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Toggle("Viewed", isOn: viewedBinding)
                    .toggleStyle(.checkbox)
                Spacer()
                if let key = stream.issueKey {
                    Text(key)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            .quaternary,
                            in: RoundedRectangle(
                                cornerRadius: 6
                            )
                        )
                    if let url = jiraBrowseURL(issueKey: key) {
                        Link(destination: url) {
                            Image(systemName: "safari")
                                .imageScale(.medium)
                                .padding(6)
                                .contentShape(Rectangle())
                        }
                        .help("Open in Jira")
                    }
                }
                Menu {
                    Button(
                        "Remove workstream from standup",
                        role: .destructive
                    ) {
                        var updatedStand = stand
                        updatedStand.removeWorkstream(stream.id)
                        space.updateStandup(updatedStand)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
            .padding(.bottom, 4)
            if entry.reviewedAt == nil {
                Section {
                    WorkstreamEntryUpdatesPanel(
                        space: $space,
                        stand: stand,
                        entry: entry
                    )
                    .padding(.vertical, 6)
                }
                Section {
                    WorkstreamEntryMinus24View(
                        space: $space,
                        stand: stand,
                        entry: entry
                    )
                    .padding(.vertical, 6)
                } header: {
                    Text("-24")
                        .font(.headline)
                        .fontDesign(.monospaced)
                }
                Section {
                    WorkstreamEntryPlus24View(
                        space: $space,
                        stand: stand,
                        entry: entry
                    )
                    .padding(.vertical, 6)
                } header: {
                    Text("+24")
                        .font(.headline)
                        .fontDesign(.monospaced)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("-24")
                            .font(.headline)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.secondary)
                        if let text = entry.minus24, !text.isEmpty {
                            Text(text)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        } else {
                            Text("No summary provided")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("+24")
                            .font(.headline)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.secondary)
                        if let text = entry.plus24, !text.isEmpty {
                            Text(text)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        } else {
                            Text("No plan provided")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.separator, lineWidth: 1)
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var space = Workspace()
        @State private var card: (Standup, Standup.WorkstreamEntry, Workstream)?

        var body: some View {
            Group {
                if let (stand, entry, stream) = card {
                    EditStandEntryCard(space: $space, stand: stand, entry: entry, stream: stream)
                } else {
                    Text("Loading…")
                }
            }
            .frame(width: 500)
            .padding()
            .environment(UserSettings())
            .environment(WorkspaceOverlayViewModel())
            .onAppear {
                guard card == nil else { return }
                let ws1Id = space.createWorkstream("Workstream 1", "WORK-1")
                let stand1Id = space.createStandup("Standup 1")
                space.publishStandup(stand1Id)
                space.addWorkstreamEntry(ws1Id, "I completed something")
                if let stand = space.stands.last,
                   let entry = stand.entries.first,
                   let stream = space.getStream(entry.workstreamId) {
                    card = (stand, entry, stream)
                }
            }
        }
    }
    return PreviewWrapper()
}
