//
//  HUDUpdateContentView.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/19/25.
//

import SwiftUI

struct HUDUpdateContentView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var models: [Workstream]
    @State var selectedId: Workstream.ID!
    @State var text = ""
    
    var selectedIndex: Int? {
        models.findIndex(id: selectedId)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                GrowingTextView2UI(
                    text: $text,
                    placeholder: "Type your update here",
                ) {
                    print("Submit")
                    if let index = selectedIndex {
                        models[index].appendUpdate(
                            .today,
                            body: text
                        )
                        text = ""
                        dismiss()
                    }
                }
                .font(.title3)
                .padding(12)
                .background(Color(NSColor.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            HStack(spacing: 6) {
                Picker("", selection: $selectedId) {
                    ForEach(models.active, id: \.id) { model in
                        Text(model.description)
                            .tag(model.id)
                    }
                }
                .controlSize(.small)
                .pickerStyle(.menu)
                Button {
//                    NSApp.appDelegate?.showWorkstreamNavWindow(selectID: selectedId)
                } label: {
                    Image(
                        systemName: "macwindow.on.rectangle"
                    )
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                Spacer()
                Button("Update") {
                    if let index = selectedIndex {
                        models[index].appendUpdate(.today, body: text)
                        text = ""
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty)
            }
            .padding(6)
        }
        .onAppear {
            if selectedId == nil {
                selectedId = models.active.first?.id
            }
        }
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous
            )
        )
        .frame(
            minWidth: 300,
            maxWidth: 600,
            minHeight: 200,
            maxHeight: 400
        )
    }
}

#Preview {
    HUDUpdateContentView(
        models: .constant(
            [
                Workstream(),
                Workstream()
            ]
        )
    )
}
