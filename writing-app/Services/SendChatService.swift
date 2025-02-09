//
//  SendChatService.swift
//  writing-app
//
//  Created by Otto Kunkel on 2/8/25.
//

import Foundation

enum MarkdownError: Error {
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
}

class MarkdownService {
    private let baseURL = "http://localhost:8000"
    
    func fetchMarkdown() async throws -> String {
        // Create request URL
        guard let url = URL(string: "\(baseURL)/markdown") else {
            throw MarkdownError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MarkdownError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw MarkdownError.serverError(httpResponse.statusCode)
            }
            
            // Convert response data to string
            guard let markdownContent = String(data: data, encoding: .utf8) else {
                throw MarkdownError.invalidResponse
            }
            
            return markdownContent
        } catch {
            throw MarkdownError.networkError(error)
        }
    }
}
