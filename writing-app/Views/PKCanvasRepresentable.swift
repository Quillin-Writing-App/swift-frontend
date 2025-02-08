import SwiftUI
import PencilKit

struct PKCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var editMode: EditMode
    let drawingController: DrawingCanvasViewController
    
    init(canvasView: Binding<PKCanvasView>, editMode: Binding<EditMode>) {
        self._canvasView = canvasView
        self._editMode = editMode
        self.drawingController = DrawingCanvasViewController()
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        
        drawingController.canvasView = canvasView
        drawingController.editMode = editMode
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        drawingController.editMode = editMode
    }
}
