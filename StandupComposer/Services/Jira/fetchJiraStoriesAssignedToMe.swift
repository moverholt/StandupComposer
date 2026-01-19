import Foundation

struct JiraStory: Identifiable {
    let key: String
    let summary: String
    var id: String { key }
}

private struct SearchResponse: Decodable {
    let issues: [SearchIssue]?
}

private struct SearchIssue: Decodable {
    let key: String
    let fields: SearchFields
}

private struct SearchFields: Decodable {
    let summary: String
}

func fetchJiraStoriesAssignedToMe(url: String, token: String) async throws -> [JiraStory] {
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
    let query = "jql=assignee%3DcurrentUser()%20AND%20issuetype%3DStory&fields=key,summary&maxResults=100&orderBy=updated%20DESC"
    let urlString = base + "/rest/api/2/search?" + query
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

    let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
    return (decoded.issues ?? []).map { JiraStory(key: $0.key, summary: $0.fields.summary) }
}
