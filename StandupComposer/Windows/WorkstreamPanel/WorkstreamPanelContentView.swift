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
    
    private func handleSubmit() {
        if text.isEmpty { return }
        space.addWorkstreamEntry(stream.id, text)
        text = ""
        position.scrollTo(edge: .bottom)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(stream.title)
                    .font(.title)
                    .textSelection(.enabled)
                Spacer()
                HStack {
                    Button(
                        action: {
                            NSApp.appDelegate?.showWorkstreamInWorkspace(
                                stream.id
                            )
                            dismiss()
                        }
                    ) {
                        Image(systemName: "uiwindow.split.2x1")
                    }
                    Button(
                        action: {
                            dismiss()
                        }
                    ) {
                        Image(systemName: "xmark")
                    }
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if stream.entries.isEmpty {
                        Text("No updates")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                    } else {
                        ForEach(stream.entries) { entry in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundStyle(.tertiary)
                                Text(entry.body)
                                    .font(.title3)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .scrollPosition($position)
            VStack(spacing: 0) {
                GrowingTextView2UI(
                    text: $text,
                    placeholder: "Add a new update"
                ) {
                    handleSubmit()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThickMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.separator, lineWidth: 1)
                )
                HStack {
                    Button("Clear") {
                        text = ""
                    }
                    .buttonStyle(.bordered)
                    .disabled(text.isEmpty)
                    Spacer()
                    Button("Add update") {
                        handleSubmit()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(text.isEmpty)
                }
                .controlSize(.small)
            }
        }
        .scenePadding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
        )
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
