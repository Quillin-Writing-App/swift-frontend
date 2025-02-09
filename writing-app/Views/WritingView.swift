import SwiftUI
import PencilKit
import Foundation

class DrawingState: ObservableObject {
    @Published var editMode: EditMode = .draw
}

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
    @State private var isUploading = false
    @State private var uploadError: String? = nil
    @State private var uploadedUrl: String? = nil
    @State private var isSidebarVisible = false
    @StateObject private var drawingState = DrawingState()
    
    private let imageService = ImageUploadService()
    // MARK: - Method
    func exportDrawing(from controller: DrawingCanvasViewController) {
            let (selectedIndices, _) = controller.getLassoSelection()
            
            let exportedImage = if selectedIndices.isEmpty {
                imageService.exportEntireCanvas(canvasView)
            } else {
                imageService.exportSelectedStrokes(from: canvasView, indices: selectedIndices)
            }
            
            uploadImage(exportedImage)
        }
        
        private func uploadImage(_ image: UIImage) {
            isUploading = true
            
            Task {
                do {
                    let url = try await imageService.uploadImage(image)
                    await MainActor.run {
                        isUploading = false
                        uploadedUrl = url
                        showingExportSheet = true
                    }
                } catch {
                    await MainActor.run {
                        isUploading = false
                        uploadError = error.localizedDescription
                    }
                }
            }
        }
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            MenuBarView(
                returnHome: {},
                onNewNote: { showingNewNoteAlert = true },
                onUndo: { canvasView.undoManager?.undo() },
                onRedo: { canvasView.undoManager?.redo() },
                onExport:{
                    let controller = DrawingCanvasViewController()
                    controller.canvasView = canvasView
                    exportDrawing(from: controller)
                },
                onToggleSidebar: { withAnimation { isSidebarVisible.toggle() } },
                drawingState: drawingState
            )
            ZStack(alignment: .trailing) {
                            PKCanvasRepresentable(canvasView: $canvasView, editMode: $drawingState.editMode)
                                .ignoresSafeArea()
                            
                            if isSidebarVisible {
                                SidebarView()
                                    .frame(width: 500)
                                    .transition(.move(edge: .trailing))
                                    .zIndex(1)
                            }
                        }
        }.environmentObject(drawingState)
    }
}

#Preview {
    WritingView()
}
