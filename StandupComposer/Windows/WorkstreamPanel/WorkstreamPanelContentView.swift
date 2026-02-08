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
    let stream: Workstream

    @State private var text = ""
    @State private var position = ScrollPosition(edge: .bottom)

    private var entriesByDay: [IsoDay: [Workstream.Entry]] {
        Dictionary(grouping: stream.entries, by: \.day)
    }

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
                Text(stream.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                HStack(spacing: 2) {
                    Button(action: {
                        NSApp.appDelegate?.showWorkstreamInWorkspace(stream.id)
                        dismiss()
                    }) {
                        Image(systemName: "uiwindow.split.2x1")
                    }
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
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
                stream: stream
            )
        }
    }
    .frame(width: 400, height: 200)
    .onAppear{
        let _ = space.createWorkstream("Preview stream")
    }
}
