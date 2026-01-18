//
//  streamOpenAIChat.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/27/25.
//

import Foundation


private struct OpenAIStreamEvent: Decodable {
    let type: String
    let delta: String?
}

func streamOpenAIChat(prompt: String) -> AsyncThrowingStream<String, Error> {
    let key = UserSettings.shared.openAIApiKey ?? "no-key"
    let host = UserSettings.shared.openAIApiUrl
    let config = OpenAIConfig(apiKey: key)
    
    struct RequestBody: Encodable {
        struct Message: Encodable {
            let role: String
            let content: String
        }
        
        let model: String
        let input: [Message]
        let stream: Bool
    }
    
    let url = URL(string: "\(host)/responses")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
    
    let body = RequestBody(
        model: config.model,
        input: [.init(role: "user", content: prompt)],
        stream: true
    )
    
    // If this throws, it happens synchronously when building the body
    request.httpBody = try? JSONEncoder().encode(body)
    
    return AsyncThrowingStream { continuation in
        Task {
            do {
                let (bytes, response) = try await URLSession.shared.bytes(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    
                    var errorData = Data()
                    for try await chunk in bytes {
                        errorData.append(chunk)
                    }
                    let message = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                    
                    let error = NSError(
                        domain: "OpenAI",
                        code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                        userInfo: [NSLocalizedDescriptionKey: message]
                    )
                    
                    continuation.finish(throwing: error)
                    return
                }
                
                var accumulated = ""
                
                for try await line in bytes.lines {
                    guard line.hasPrefix("data: ") else { continue }
                    
                    let jsonString = String(line.dropFirst("data: ".count))
                    
                    if jsonString == "[DONE]" {
                        break
                    }
                    
                    guard let data = jsonString.data(using: .utf8) else { continue }
                    
                    if let event = try? JSONDecoder().decode(OpenAIStreamEvent.self, from: data),
                       event.type == "response.output_text.delta",
                       let delta = event.delta {
                        
                        accumulated.append(delta)
                        
                        // Match old behavior: yield the accumulated text
                        continuation.yield(accumulated)
                        
                        // If you want just the new piece instead, use:
                        // continuation.yield(delta)
                    }
                }
                
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
