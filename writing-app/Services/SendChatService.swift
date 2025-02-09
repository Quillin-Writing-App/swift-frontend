import Foundation

enum ChatError: Error {
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
    case encodingError
}

class ChatService: ObservableObject {
    private let baseURL = "http://localhost:8000"
    
    func sendMessage(_ message: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw ChatError.invalidResponse
        }
        
        // Create URL components to send message as form data
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "message", value: message)
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Print the response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatError.invalidResponse
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw ChatError.serverError(httpResponse.statusCode)
            }
            
            // Parse the response according to the API format
            struct ChatResponse: Codable {
                let content: String
            }
            
            let jsonResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return jsonResponse.content
            
        } catch {
            print("Error details: \(error)")
            throw ChatError.networkError(error)
        }
    }
}
