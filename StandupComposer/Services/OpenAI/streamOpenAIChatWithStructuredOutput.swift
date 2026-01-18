//
//  streamOpenAIChatWithStructuredOutput.swift
//  StandupComposer
//
//  Created by Matt Overholt on 1/11/26.
//

import Foundation
import Playgrounds

private struct OpenAIStreamEvent: Decodable {
    let type: String
    let delta: String?
}

private struct TextFormat: Encodable {
    let type: String
}

private struct Text: Encodable {
    let format: TextFormat
}

private struct StructuredOutputRequestBody: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }
    
    let model: String
    let input: [Message]
    let stream: Bool
    let text: Text
}

func streamOpenAIChatWithStructuredOutput<T: Decodable>(
    prompt: String,
    responseType: T.Type
) -> AsyncThrowingStream<T, Error> {
    let key = UserSettings.shared.openAIApiKey ?? "no-key"
    let host = UserSettings.shared.openAIApiUrl
    let config = OpenAIConfig(apiKey: key)
    
    let url = URL(string: "\(host)/responses")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
    
    let body = StructuredOutputRequestBody(
        model: config.model,
        input: [StructuredOutputRequestBody.Message(role: "user", content: prompt)],
        stream: true,
        text: Text(format: TextFormat(type: "json_object"))
    )
    
    request.httpBody = try? JSONEncoder().encode(body)
    
    return AsyncThrowingStream { continuation in
        Task {
            do {
                let (bytes, response) = try await URLSession.shared.bytes(for: request)
                
//                print("Response: ")
//                let resp = response as? HTTPURLResponse
//                print("Status code: \(resp?.statusCode.description)")
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    
                    var errorData = Data()
                    for try await chunk in bytes {
                        errorData.append(chunk)
                    }
                    let message = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                    print("Error body: \(message)")
                    
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
                    }
                }
                
                guard let jsonData = accumulated.data(using: .utf8) else {
                    let error = NSError(
                        domain: "OpenAI",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to convert accumulated JSON to Data"]
                    )
                    continuation.finish(throwing: error)
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: jsonData)
                    continuation.yield(decoded)
                    continuation.finish()
                } catch {
                    let error = NSError(
                        domain: "OpenAI",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON: \(error.localizedDescription)"]
                    )
                    continuation.finish(throwing: error)
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}

#Playground {
    struct TestResponse: Decodable {
        let summary: String
        let status: String
    }
    
    let prompt = "Return a JSON object with summary and status fields"
    let stream = streamOpenAIChatWithStructuredOutput(
        prompt: prompt,
        responseType: TestResponse.self
    )
    
    print("Streaming response ...")
    Task {
        for try await resp in stream {
            print(resp)
        }
    }
}
