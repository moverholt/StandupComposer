//
//  WorkspaceNewWorkstreamView.swift
//  StandupComposer
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct WorkspaceNewWorkstreamView: View {
    @Binding var streams: [Workstream]
    @Binding var selected: WorkspaceSelected
    
    @State private var title = "New Workstream"
    
    private func handleSubmit() {
        if title.isEmpty {
            return
        }
        var stream = Workstream()
        stream.title = title
        streams.append(stream)
        selected = .workstream(stream.id)
    }
    
    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .font(.title)
                .onSubmit {
                    handleSubmit()
                }
            Spacer()
            Button(
                action: {
                    handleSubmit()
                }
            ) {
                Label("Create Workstream", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .scenePadding()
    }
}

#Preview {
    @Previewable @State var models: [Workstream] = []
    @Previewable @State var selected = WorkspaceSelected.none
    WorkspaceNewWorkstreamView(
        streams: $models,
        selected: $selected
    )
}
