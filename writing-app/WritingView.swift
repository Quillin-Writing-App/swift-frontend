//
//  ContentView.swift
//  writing-app
//
//  Created by Otto Kunkel on 2/8/25.
//

import SwiftUI
import PencilKit


enum EditMode {
    case draw
    case panSelect
}

struct MenuBarView: View {
    var onNewNote: () -> Void
    var onUndo: () -> Void
    var onRedo: () -> Void
    var onExport: () -> Void  // Add export action
    @Binding var editMode: EditMode
    
    var body: some View {
        HStack {
            Button(action: onNewNote) {
                Image(systemName: "doc.badge.plus")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            // Export button
            Button(action: onExport) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Mode toggle button
            Button(action: {
                editMode = editMode == .draw ? .panSelect : .draw
            }) {
                Image(systemName: editMode == .draw ? "pencil" : "hand.draw")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Button(action: onUndo) {
                Image(systemName: "arrow.uturn.backward")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Button(action: onRedo) {
                Image(systemName: "arrow.uturn.forward")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.black.opacity(0.9))
    }
}

struct Note: Identifiable {
    let id = UUID()
    var drawing: PKDrawing
    var title: String
    var createdAt: Date
    var transform: CGAffineTransform = .identity // Add transform property
}

class DrawingCanvasViewController: UIViewController {
    weak var canvasView: PKCanvasView?
    var selectedStroke: PKStroke?
    var originalTransform: CGAffineTransform?
    var editMode: EditMode = .draw {
        didSet {
            updateToolForMode()
        }
    }
    
    private func updateToolForMode() {
        switch editMode {
        case .draw:
            canvasView?.tool = PKInkingTool(.pen, color: .black, width: 3)
        case .panSelect:
            canvasView?.tool = PKLassoTool()
        }
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        
        canvasView?.addGestureRecognizer(tapGesture)
        canvasView?.addGestureRecognizer(panGesture)
        
        // Only enable gestures in pan/select mode
        tapGesture.isEnabled = false
        panGesture.isEnabled = false
        
        // Update gesture recognizers based on mode
        updateGestureRecognizers()
    }
    
    private func updateGestureRecognizers() {
        canvasView?.gestureRecognizers?.forEach { gesture in
            if gesture is UITapGestureRecognizer || gesture is UIPanGestureRecognizer {
                gesture.isEnabled = editMode == .panSelect
            }
        }
    }
    
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
    
    private var selectedStrokeIndex: Int?
    
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




struct WritingView: View {
    @State private var canvasView = PKCanvasView()
    @State private var notes: [Note] = []
    @State private var currentNoteIndex: Int? = nil
    @State private var showingNewNoteAlert = false
    @State private var newNoteTitle = ""
    @State private var editMode: EditMode = .draw
    @State private var showingExportSheet = false
    @State private var exportImage: UIImage? = nil
    
    func exportDrawing() {
            // Create an image from the canvas
            let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
            let image = renderer.image { context in
                canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
            }
            exportImage = image
            showingExportSheet = true
        }
    
    var body: some View {
            VStack(spacing: 0) {
                MenuBarView(
                    onNewNote: { showingNewNoteAlert = true },
                    onUndo: {
                        canvasView.undoManager?.undo()
                    },
                    onRedo: {
                        canvasView.undoManager?.redo()
                    },
                    onExport: exportDrawing,
                    editMode: $editMode
                )
                
                PKCanvasRepresentable(canvasView: $canvasView, editMode: $editMode)
                    .ignoresSafeArea()
            }
        }
}

#Preview {
    WritingView()
}
