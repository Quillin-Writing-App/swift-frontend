import UIKit
import PencilKit

class DrawingCanvasViewController: UIViewController {
    weak var canvasView: PKCanvasView?
    var selectedStroke: PKStroke?
    var selectedStrokeIndex: Int?
    var originalTransform: CGAffineTransform?
    var editMode: EditMode = .draw {
        didSet {
            updateToolForMode()
        }
    }
    
    // MARK: - Tool Management
    private func updateToolForMode() {
        switch editMode {
        case .draw:
            canvasView?.tool = PKInkingTool(.pen, color: .black, width: 3)
        case .panSelect:
            canvasView?.tool = PKLassoTool()
        case .erase:
            canvasView?.tool = PKEraserTool(.vector)
        }
        
    }
    
    // MARK: - Gesture Setup
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        
        canvasView?.addGestureRecognizer(tapGesture)
        canvasView?.addGestureRecognizer(panGesture)
        
        tapGesture.isEnabled = false
        panGesture.isEnabled = false
        
        updateGestureRecognizers()
    }
    
    private func updateGestureRecognizers() {
        canvasView?.gestureRecognizers?.forEach { gesture in
            if gesture is UITapGestureRecognizer || gesture is UIPanGestureRecognizer {
                gesture.isEnabled = editMode == .panSelect
            }
        }
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard editMode == .panSelect else { return }
        
        let location = gesture.location(in: canvasView)
        
        if selectedStroke != nil {
            selectedStroke = nil
            selectedStrokeIndex = nil
            canvasView?.setNeedsDisplay()
            return
        }
        
        if let (stroke, index) = findStroke(at: location) {
            selectedStroke = stroke
            selectedStrokeIndex = index
            originalTransform = stroke.transform
            canvasView?.setNeedsDisplay()
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard editMode == .panSelect,
              let selectedStroke = selectedStroke,
              let strokeIndex = selectedStrokeIndex else { return }
        
        let translation = gesture.translation(in: canvasView)
        
        switch gesture.state {
        case .began:
            originalTransform = selectedStroke.transform
        case .changed:
            var newTransform = originalTransform ?? .identity
            newTransform = newTransform.translatedBy(x: translation.x, y: translation.y)
            
            let updatedStroke = PKStroke(
                ink: selectedStroke.ink,
                path: selectedStroke.path,
                transform: newTransform,
                mask: selectedStroke.mask
            )
            
            var strokes = canvasView?.drawing.strokes ?? []
            if strokes.indices.contains(strokeIndex) {
                strokes[strokeIndex] = updatedStroke
                canvasView?.drawing = PKDrawing(strokes: strokes)
                self.selectedStroke = updatedStroke
            }
        case .ended:
            originalTransform = nil
        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    private func findStroke(at point: CGPoint) -> (PKStroke, Int)? {
        guard let strokes = canvasView?.drawing.strokes else { return nil }
        
        for (index, stroke) in strokes.enumerated() {
            let renderBounds = stroke.renderBounds
            if renderBounds.contains(point) {
                return (stroke, index)
            }
        }
        return nil
    }
}
