import Foundation

private struct JiraMyselfResponse: Decodable {
    let displayName: String?
    let name: String?
    let key: String?
}

func testJiraConnection(url: String, token: String) async throws -> String {
    var base = url.trimmingCharacters(in: .whitespacesAndNewlines)
    if base.isEmpty {
        throw NSError(domain: "Jira", code: -1, userInfo: [NSLocalizedDescriptionKey: "Jira URL is required"])
    }
    if token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        throw NSError(domain: "Jira", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token is required"])
    }
    if base.hasSuffix("/") {
        base = String(base.dropLast())
    }
    let urlString = base + "/rest/api/2/myself"
    guard let reqURL = URL(string: urlString) else {
        throw NSError(domain: "Jira", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Jira URL"])
    }
    var request = URLRequest(url: reqURL)
    request.httpMethod = "GET"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "Jira", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }

    guard (200..<300).contains(httpResponse.statusCode) else {
        let body = String(data: data, encoding: .utf8) ?? "Unknown error"
        let msg: String
        if httpResponse.statusCode == 401 {
            msg = "Unauthorized: check access token"
        } else if httpResponse.statusCode == 404 {
            msg = "Not found: is Jira at \(base)? Try /rest/api/2 or /rest/api/3"
        } else {
            msg = "HTTP \(httpResponse.statusCode): \(body)"
        }
        throw NSError(domain: "Jira", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
    }

    let decoded = try JSONDecoder().decode(JiraMyselfResponse.self, from: data)
    return decoded.displayName ?? decoded.name ?? decoded.key ?? "Connected"
}
