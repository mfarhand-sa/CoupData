//
//  CDOpenAIManager.swift
//  CoupDate
//
//  Created by mo on 2024-10-23.
//

import Foundation


import Foundation

// Define a model to parse the OpenAI response
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let role: String
    let content: String
}

class OpenAIManager {
    static let shared = OpenAIManager()
    private let apiKey = "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" // Replace with your API Key

    // This method sends a text to the OpenAI API via OpenRouter and extracts the response
    func fetchOpenAIResponse(prompt: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Construct the request body
        let requestBody: [String: Any] = [
            "model": "openai/chatgpt-4o-latest",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an assistant that reframes text and extracts insights based on personality, desire, bias, and emotions."                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        // Convert the body to JSON data
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            completion(nil)
            return
        }
        
        request.httpBody = httpBody
        
        // Make the API call using URLSession
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API call: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // Parse the JSON response
            do {
                let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                let result = decodedResponse.choices.first?.message.content
                completion(result)
            } catch {
                print("Error parsing response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
