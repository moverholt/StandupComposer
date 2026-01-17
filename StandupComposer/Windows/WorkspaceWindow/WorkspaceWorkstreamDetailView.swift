//
//  WorkspaceWorkstreamDetailView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceWorkstreamDetailView: View {
    @Binding var stream: Workstream
    
    @State private var text = ""
    @State private var position = ScrollPosition(edge: .bottom)
    
    private var last60Days: [IsoDay] {
        (0..<60).map({ IsoDay.today.subDays($0) }).reversed()
    }
    
    private func handleSubmit() {
        if text.isEmpty {
            return
        }
        stream.appendUpdate(.today, body: text)
        text = ""
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(stream.title)
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        Button {
                            NSApp.appDelegate?.showWorkstreamPanel(stream.id)
                        } label: {
                            Image(systemName: "macwindow.on.rectangle")
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                    }
                    if stream.status != .active {
                        Text(stream.status.description)
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if let issue = stream.issueKey {
                        HStack(spacing: 8) {
                            Text(issue)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                            if let url = URL(
                                string: "https://myjira-temp.com/\(issue)"
                            ) {
                                Link(destination: url) {
                                    Image(systemName: "safari")
                                        .imageScale(.medium)
                                        .padding(6)
                                        .contentShape(Rectangle())
                                }
                                .help("Open in browser")
                            }
                        }
                    }
                }
            }
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(last60Days) { day in
                        if stream.logItemsByDay[day] != nil {
                            Text(day.formatted(style: .abbreviated))
                                .font(.largeTitle)
                            if let plans = stream.plansByDay[day] {
                                WorkstreamPlansDay(
                                    plans: plans,
                                    stream: $stream
                                )
                            }
                            if let updates = stream.updatesByDay[day] {
                                WorkstreamUpdatesDay(
                                    updates: updates,
                                    stream: $stream
                                )
                            }
                        }
                    }
                }
            }
            .scrollPosition($position)
            GrowingTextView2UI(
                text: $text,
                placeholder: "Write update here ..."
            ) {
                handleSubmit()
            }
            .padding(6)
            .background(
                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(.ultraThickMaterial)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 12
                )
                .stroke(.separator, lineWidth: 1)
            )
            HStack {
                Button("Clear") {
                    text = ""
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .disabled(text == "")
                Spacer()
                Button("Add") {
                    handleSubmit()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(text == "")
            }
        }
        .onChange(of: stream.updates.count) {
            position.scrollTo(edge: .bottom)
        }
    }
}

#Preview {
    @Previewable @State var stream = Workstream()
    WorkspaceWorkstreamDetailView(stream: $stream)
        .onAppear {
            stream.issueKey = "TEST-123"
            stream.appendUpdate(.today, body: "This is an update")
        }
}
