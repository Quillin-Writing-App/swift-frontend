//
//  ContentView.swift
//  writing-app
//
//  Created by Otto Kunkel on 2/8/25.
//

import SwiftUI
import PencilKit


// Save drawing
func savePKDrawing(_ drawing: PKDrawing) {
    let drawingData = drawing.dataRepresentation()
    UserDefaults.standard.set(drawingData, forKey: "savedDrawing")
    // Or save to documents directory:
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let drawingURL = documentDirectory.appendingPathComponent("drawing.data")
    try? drawingData.write(to: drawingURL)
}

// Load drawing
func loadPKDrawing() -> PKDrawing? {
    if let drawingData = UserDefaults.standard.data(forKey: "savedDrawing") {
        return try? PKDrawing(data: drawingData)
    }
    return nil
}


struct PKCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}


struct WritingView : View {
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
            VStack(spacing: 0) { // spacing: 0 removes gap between menu and canvas
                MenuBarView()
                
                PKCanvasRepresentable(canvasView: $canvasView)
                    .ignoresSafeArea()
            }
        }
}

#Preview {
    WritingView()
}
