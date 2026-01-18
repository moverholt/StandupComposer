//
//  SettingsWindowContentView.swift
//  FEJournal
//
//  Created by Matt Overholt on 12/30/25.
//

import SwiftUI

struct SettingsWindowContentView: View {
    @Environment(UserSettings.self) var settings: UserSettings
    
    var body: some View {
        Form {
            Section("OpenAI") {
                TextField(
                    "API Key",
                    text: Binding(
                        get: { settings.openAIApiKey ?? "" },
                        set: {
                            if $0.isEmpty {
                                settings.openAIApiKey = nil
                            } else {
                                settings.openAIApiKey = $0
                            }
                        }
                    )
                )
                TextField(
                    "API Host",
                    text: Binding(
                        get: { settings.openAIApiUrl },
                        set: {
                            if $0.isEmpty {
                                settings.openAIApiUrl = UserSettings.defaultOpenAIHost
                            } else {
                                settings.openAIApiUrl = $0
                            }
                        }
                    )
                )
            }
        }
        .frame(
            minWidth: 400,
            maxWidth: 800
        )
    }
}

#Preview {
    SettingsWindowContentView()
}
