import Foundation

func testOpenAIConnection(apiKey: String, host: String) async throws -> String {
    let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    if key.isEmpty {
        throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key is required"])
    }
    var base = host.trimmingCharacters(in: .whitespacesAndNewlines)
    if base.isEmpty {
        base = UserSettings.defaultOpenAIHost
    }
    if base.hasSuffix("/") {
        base = String(base.dropLast())
    }
    guard let url = URL(string: "\(base)/v1/models") else {
        throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API host URL"])
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }

    guard (200..<300).contains(httpResponse.statusCode) else {
        let body = String(data: data, encoding: .utf8) ?? "Unknown error"
        let msg: String
        if httpResponse.statusCode == 401 {
            msg = "Unauthorized: check API key"
        } else {
            msg = "HTTP \(httpResponse.statusCode): \(body)"
        }
        throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
    }

    return "Connected"
}
