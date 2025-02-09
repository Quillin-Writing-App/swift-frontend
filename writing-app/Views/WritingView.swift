import SwiftUI
import PencilKit
import Foundation

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
    
    
    // MARK: - Method
    private func exportDrawing() {
            let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
            let image = renderer.image { context in
                canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
            }
            
            // Upload the image
            isUploading = true
            
            Task {
                do {
                    let imageUploadService = ImageUploadService()
                    let url = try await imageUploadService.uploadImage(image)
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
                onExport: exportDrawing,
//                onToggleSidebar: { withAnimation { isSidebarVisible.toggle() } },
                editMode: $editMode
            )
            HStack(spacing: 0) {
                PKCanvasRepresentable(canvasView: $canvasView, editMode: $editMode)
                    .ignoresSafeArea()
    
                if isSidebarVisible {
                    SidebarView()
                        .transition(.move(edge: .trailing))
                }
            }
        }
    }
}

#Preview {
    WritingView()
}
