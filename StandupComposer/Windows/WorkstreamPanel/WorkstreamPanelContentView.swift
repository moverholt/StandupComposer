//
//  WorkstreamPanelContentView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/31/25.
//

import SwiftUI

struct WorkstreamPanelContentView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var model: Workstream
    @State private var text = ""
    @State private var position = ScrollPosition(edge: .bottom)
    
    private func handleSubmit() {
        if text.isEmpty {
            return
        }
        model.appendUpdate(.today, body: text)
        text = ""
        position.scrollTo(edge: .bottom)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(model.title)
                    .font(.title)
                    .textSelection(.enabled)
                Spacer()
                HStack {
                    Button(
                        action: {
                            NSApp.appDelegate?.showWorkstreamInWorkspace(model.id)
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
                LazyVStack(
                    alignment: .leading,
                    spacing: 0
                ) {
                    ForEach(model.daysWithUpdates) { day in
                        Text(day.formatted(style: .complete))
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        Divider()
                            .padding(.bottom)
                        DayUpdates(
                            updates: model.updatesByDay[day] ?? []
                        )
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
                    Button("Add Update") {
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
    @Previewable @State var model = Workstream()
    WorkstreamPanelContentView(model: $model)
        .frame(width: 400, height: 200)
        .onAppear{
            model.appendUpdate(.yesterday, body: "I did some work!")
            model.appendUpdate(.today, body: "I did some more work!")
        }
}
