import Foundation
import SwiftUI
import PencilKit

enum ImageUploadError: Error {
    case invalidImage
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
}

class ImageUploadService {
    private let baseURL = "http://localhost:8000"
    
    // MARK: - Drawing Export Methods
    func exportEntireCanvas(_ canvasView: PKCanvasView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        return renderer.image { context in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
    }
    
    func exportSelectedStrokes(from canvasView: PKCanvasView, indices: [Int]) -> UIImage {
        // Get the selected strokes
        let selectedStrokes = indices.compactMap { index -> PKStroke? in
            guard index < canvasView.drawing.strokes.count else { return nil }
            return canvasView.drawing.strokes[index]
        }
        
        // Calculate bounds for selected strokes
        let selectedBounds = selectedStrokes.reduce(CGRect.null) { result, stroke in
            return result.union(stroke.renderBounds)
        }.insetBy(dx: -20, dy: -20) // Add padding
        
        // Create and draw the image
        let renderer = UIGraphicsImageRenderer(bounds: selectedBounds)
        return renderer.image { context in
            // Set white background
            UIColor.white.setFill()
            context.fill(selectedBounds)
            
            // Draw the selected strokes
            let selectedDrawing = PKDrawing(strokes: selectedStrokes)
            selectedDrawing.image(from: selectedBounds, scale: UIScreen.main.scale)
                .draw(in: selectedBounds)
        }
    }
    
    // MARK: - Upload Methods
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
