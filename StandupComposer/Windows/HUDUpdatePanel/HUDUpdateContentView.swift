//
//  HUDUpdateContentView.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/19/25.
//

import SwiftUI

struct HUDUpdateContentView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var space: Workspace
    @State var selectedId: Workstream.ID?
    @State var text = ""
    
    private func handleSubmit() {
        guard let id = selectedId, !text.isEmpty else { return }
        space.addWorkstreamEntry(id, text)
        text = ""
        dismiss()
    }

    var body: some View {
        VStack(spacing: 0) {
            if space.streams.active.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text("No Workstreams")
                        .font(.headline)
                    Text("Create a workstream in the workspace first to start adding updates.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack {
                    Picker("", selection: $selectedId) {
                        ForEach(space.streams.active, id: \.id) { stream in
                            Text(stream.description)
                                .tag(stream.id)
                        }
                    }
                    .controlSize(.small)
                    .pickerStyle(.menu)
                    .labelsHidden()
                    Button {
                        if let id = selectedId {
                            NSApp.appDelegate?.showWorkstreamPanel(id)
                        }
                    } label: {
                        Image(systemName: "macwindow.on.rectangle")
                            .imageScale(.small)
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.accessoryBar)
                    .foregroundStyle(.secondary)
                    .disabled(selectedId == nil)
                    .help("Open workstream panel")
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

                Divider()

                Spacer(minLength: 0)

                VStack(spacing: 8) {
                    SubmittableTextView(
                        text: $text,
                        placeholder: "Type your update here"
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
                        Button("Update") {
                            handleSubmit()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .disabled(text.isEmpty)
                    }
                }
                .padding(10)
            }
        }
        .frame(
            minWidth: 280, idealWidth: 340, maxWidth: 500,
            minHeight: 180, idealHeight: 260, maxHeight: 400
        )
        .onAppear {
            if selectedId == nil {
                selectedId = space.streams.active.first?.id
            }
        }
        
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(2)
    }
}

#Preview {
    @Previewable @State var space = Workspace()
    HUDUpdateContentView(space: $space)
        .frame(width: 300, height: 300)
        .onAppear {
            let wsid = space.createWorkstream("This is a workstream", "FOOD-1234")
        }
}
