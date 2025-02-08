import SwiftUI
import PencilKit

struct WritingView: View {
    // MARK: - State
    @State private var canvasView = PKCanvasView()
    @State private var notes: [Note] = []
    @State private var currentNoteIndex: Int? = nil
    @State private var showingNewNoteAlert = false
    @State private var newNoteTitle = ""
    @State private var editMode: EditMode = .draw
    @State private var showingExportSheet = false
    @State private var exportImage: UIImage? = nil
    
    // MARK: - Methods
    private func exportDrawing() {
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        let image = renderer.image { context in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        exportImage = image
        showingExportSheet = true
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            MenuBarView(
                onNewNote: { showingNewNoteAlert = true },
                onUndo: { canvasView.undoManager?.undo() },
                onRedo: { canvasView.undoManager?.redo() },
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
