//
//  fetchOpenAIModels.swift
//  StandupComposer
//

import Foundation
import Playgrounds

private struct ModelsListResponse: Decodable {
    let data: [ModelEntry]
}

private struct ModelEntry: Decodable {
    let id: String
}

private let nonChatModelIdPrefixes = [
    "text-embedding-",
    "dall-e",
    "tts-",
    "whisper",
    "text-davinci",
    "text-curie",
    "text-babbage",
    "text-ada",
    "code-davinci",
]

func fetchOpenAIModels(filterForChat: Bool = true) async throws -> [String] {
    let apiKey = UserSettings.shared.openAIApiKey ?? "no-key"
    let host = UserSettings.shared.openAIApiUrl
    let url = URL(string: "\(host)/v1/models")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }

    guard (200..<300).contains(httpResponse.statusCode) else {
        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
    }

    let decoded = try JSONDecoder().decode(ModelsListResponse.self, from: data)
    var ids = decoded.data.map(\.id)
    if filterForChat {
        ids = ids.filter { id in
            let lower = id.lowercased()
            return !nonChatModelIdPrefixes.contains { lower.hasPrefix($0) }
        }
    }
    return ids
}

#Playground {
    Task {
        do {
            let models = try await fetchOpenAIModels()
        } catch {
            print("error", error.localizedDescription)
        }
    }
}
