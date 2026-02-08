//
//  WorkstreamPanelContentView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/31/25.
//

import SwiftUI

struct WorkstreamPanelContentView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var space: Workspace
    @Binding var stream: Workstream

    @State private var text = ""
    @State private var position = ScrollPosition(edge: .bottom)

    private var entriesByDay: [IsoDay: [Workstream.Entry]] {
        Dictionary(grouping: stream.entries, by: \.day)
    }

    @MainActor
    private var sortedDays: [IsoDay] {
        entriesByDay.keys.sorted(by: <)
    }

    private func handleSubmit() {
        if text.isEmpty { return }
        space.addWorkstreamEntry(stream.id, text)
        text = ""
        position.scrollTo(edge: .bottom)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Text(stream.title)
                        .font(.headline)
                        .lineLimit(1)
                    if let key = stream.issueKey {
                        Text(key)
                            .font(.subheadline)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    Button(action: {
                        NSApp.appDelegate?.showWorkstreamInWorkspace(stream.id)
                        dismiss()
                    }) {
                        Image(systemName: "macwindow")
                            .imageScale(.small)
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                    }
                    .help("Open in workspace")
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.small)
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                    }
                    .help("Close")
                }
                .buttonStyle(.accessoryBar)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if stream.entries.isEmpty {
                        Text("No updates yet")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                    } else {
                        ForEach(sortedDays, id: \.self) { day in
                            let entries = entriesByDay[day] ?? []
                            Text(day.sectionHeaderTitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 14)
                                .padding(.top, day == sortedDays.first ? 4 : 12)
                                .padding(.bottom, 2)
                            ForEach(entries) { entry in
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("\u{2022}")
                                        .foregroundStyle(.quaternary)
                                    Text(entry.body)
                                        .textSelection(.enabled)
                                }
                                .font(.body)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollPosition($position)

            Divider()

            VStack(spacing: 8) {
                SubmittableTextView(
                    text: $text,
                    placeholder: "Add a new update"
                ) {
                    handleSubmit()
                }
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(.quaternary.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(.separator, lineWidth: 0.5)
                )

                HStack {
                    Spacer()
                    Button("Add Update") {
                        handleSubmit()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(text.isEmpty)
                }
            }
            .padding(10)
        }
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    VStack {
        if let stream = space.streams.first {
            WorkstreamPanelContentView(
                space: $space,
                stream: Binding(
                    get: { stream },
                    set: { space.updateWorkstream($0) }
                )
            )
        }
    }
    .frame(width: 400, height: 200)
    .onAppear{
        let _ = space.createWorkstream("Preview stream", "FOOD-1234")
    }
}
