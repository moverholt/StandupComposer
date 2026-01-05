//
//  WorkspaceNewStandupView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/3/26.
//

import SwiftUI

struct WorkspaceNewStandupView: View {
    @Binding var streams: [Workstream]
    @Binding var stands: [Standup]
    @Binding var selected: WorkspaceSelected
    @State private var title: String = "New Standup"
    
    private func handleSubmit() {
        var stand = Standup(.today, title: title)
        for stream in streams.active {
            let upd = Standup.WorkstreamUpdate(stream)
            stand.updates.append(upd)
        }
        
        stands.append(stand)
        selected = .standup(stand.id)
    }
    
    private var createDisabled: Bool {
        title.isEmpty || streams.isEmpty
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title)
            }
            Spacer()
            Section(
                header: Text("Active Workstreams")
                    .foregroundStyle(.secondary)
            ) {
                if streams.isEmpty {
                    Text("No Active Workstreams")
                        .foregroundStyle(.primary)
                        .italic()
                        .padding(.vertical)
                } else {
                    VStack {
                        ForEach(streams.active) { stream in
                            Text(stream.description)
                        }
                    }
                }
            }
            Spacer()
            Button("Create", action: handleSubmit)
                .disabled(createDisabled)
                .buttonStyle(.borderedProminent)
        }
        .scenePadding()
        .onSubmit {
            handleSubmit()
        }
        .onAppear {
            title = "\(IsoDay.today.formatted(style: .complete)) - Standup"
        }
    }
}

#Preview {
    @Previewable @State var streams = [Workstream]()
    @Previewable @State var stands = [Standup]()
    @Previewable @State var selected = WorkspaceSelected.newStandup
    WorkspaceNewStandupView(
        streams: $streams,
        stands: $stands,
        selected: $selected
    )
}
