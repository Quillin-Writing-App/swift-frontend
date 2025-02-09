import Foundation
import SwiftUI

enum ImageUploadError: Error {
    case invalidImage
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
}

class ImageUploadService {
    private let baseURL = "http://localhost:8000"
    
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageUploadError.invalidImage
        }
        
        // Create upload URL
        guard let url = URL(string: "\(baseURL)/upload") else {
            throw ImageUploadError.invalidResponse
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form data
        var body = Data()
        
        // Add image data
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"drawing.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageUploadError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw ImageUploadError.serverError(httpResponse.statusCode)
            }
            
            // Parse response
            let responseDict = try JSONDecoder().decode([String: String].self, from: data)
            guard let imageUrl = responseDict["url"] else {
                throw ImageUploadError.invalidResponse
            }
            
            return imageUrl
        } catch {
            throw ImageUploadError.networkError(error)
        }
    }
}
