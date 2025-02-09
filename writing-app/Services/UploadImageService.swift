import Foundation
import SwiftUI
import PencilKit

enum ImageUploadError: Error {
    case invalidImage
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
}

enum TextUploadError: Error {
    case invalidText
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
}

class ImageUploadService {
    private let explainURL = "https://quillin.up.railway.app/explain"
    private let clarifyURL = "https://quillin.up.railway.app/clarify"
    private let memeURL = "https://quillin.up.railway.app/fenty_wap"
    
    struct ExplainResponse: Codable {
        let explanation: String
        let clarifying_prompts: [String]
    }
    
    struct MemeResponse: Codable {
        let url: String  // The JSON key you're expecting to receive
    }
    
    // MARK: - Drawing Export Methods
    func exportEntireCanvas(_ canvasView: PKCanvasView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        return renderer.image { context in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
    }
    
    func exportSelectedStrokes(from canvasView: PKCanvasView, indices: [Int]) -> UIImage {
        let selectedStrokes = indices.compactMap { index -> PKStroke? in
            guard index < canvasView.drawing.strokes.count else { return nil }
            return canvasView.drawing.strokes[index]
        }
        
        let selectedBounds = selectedStrokes.reduce(CGRect.null) { result, stroke in
            return result.union(stroke.renderBounds)
        }.insetBy(dx: -20, dy: -20)
        
        let renderer = UIGraphicsImageRenderer(bounds: selectedBounds)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(selectedBounds)
            
            let selectedDrawing = PKDrawing(strokes: selectedStrokes)
            selectedDrawing.image(from: selectedBounds, scale: UIScreen.main.scale)
                .draw(in: selectedBounds)
        }
    }
    
    // MARK: - Upload Methods
    func uploadImage(_ image: UIImage) async throws -> ExplainResponse {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageUploadError.invalidImage
        }
        
        guard let url = URL(string: explainURL) else {
            throw ImageUploadError.invalidResponse
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
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
            
            return try JSONDecoder().decode(ExplainResponse.self, from: data)
        } catch {
            throw ImageUploadError.networkError(error)
        }
    }
    
    // Upload method for fenty_wap API
        func uploadMemeImage(_ image: UIImage) async throws -> MemeResponse {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw ImageUploadError.invalidImage
            }
            
            guard let url = URL(string: memeURL) else {
                throw ImageUploadError.invalidResponse
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
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
                
                return try JSONDecoder().decode(MemeResponse.self, from: data)
            } catch {
                throw ImageUploadError.networkError(error)
            }
        }
    
    func uploadText(_ text: String) async throws -> ExplainResponse {
        guard let url = URL(string: clarifyURL) else {
            throw TextUploadError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["text": text]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TextUploadError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw TextUploadError.serverError(httpResponse.statusCode)
            }
            
            return try JSONDecoder().decode(ExplainResponse.self, from: data)
        } catch {
            throw TextUploadError.networkError(error)
        }
    }
}
