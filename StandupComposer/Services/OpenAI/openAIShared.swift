//
//  openAIShared.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import Foundation

struct OpenAIConfig {
    let apiKey: String
    let model: String
    let host: String
    
    init(_ settings: UserSettings) {
        apiKey = settings.openAIApiKey ?? "no-key"
        model = settings.openAISelectedModel
        host = settings.openAIApiUrl
    }
}

