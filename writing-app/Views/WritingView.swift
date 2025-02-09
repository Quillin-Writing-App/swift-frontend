import SwiftUI
import PencilKit
import Foundation

// MARK: - Writing View Model
class WritingViewModel: ObservableObject {
    @Published var canvasView = PKCanvasView()
    @Published var notes: [Note] = []
    @Published var currentNoteIndex: Int? = nil
    @Published var showingNewNoteAlert = false
    @Published var newNoteTitle = ""
    @Published var editMode: EditMode = .draw
    @Published var showingExportSheet = false
    @Published var isUploading = false
    @Published var uploadError: String? = nil
    @Published var uploadedUrl: String? = nil
    @Published var isSidebarVisible = false
    
    private let imageService = ImageUploadService()
    
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
}

// MARK: - Writing View
struct WritingView: View {
    @StateObject private var viewModel = WritingViewModel()
    
    // MARK: - View Components
    private var canvas: some View {
        PKCanvasRepresentable(
            canvasView: $viewModel.canvasView,
            editMode: $viewModel.editMode
        )
        .ignoresSafeArea()
    }
    
    private var menuBar: some View {
        MenuBarView(
            onNewNote: { viewModel.showingNewNoteAlert = true },
            onUndo: { viewModel.canvasView.undoManager?.undo() },
            onRedo: { viewModel.canvasView.undoManager?.redo() },
            onExport: {
                let controller = DrawingCanvasViewController()
                controller.canvasView = viewModel.canvasView
                viewModel.exportDrawing(from: controller)
            },
            onToggleSidebar: {
                withAnimation { viewModel.isSidebarVisible.toggle() }
            },
            editMode: $viewModel.editMode
        )
    }
    
    private var sidebar: some View {
        Group {
            if viewModel.isSidebarVisible {
                SidebarView()
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            menuBar
            HStack(spacing: 0) {
                canvas
                sidebar
            }
        }
        .alert("New Note", isPresented: $viewModel.showingNewNoteAlert) {
            // Add alert actions here
        }
        .sheet(isPresented: $viewModel.showingExportSheet) {
            // Add export sheet content here
        }
    }
}

// MARK: - Preview
#Preview {
    WritingView()
}
