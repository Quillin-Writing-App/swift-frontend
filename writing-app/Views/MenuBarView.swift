import SwiftUI

// MARK: - MenuBar Button
struct MenuBarButton: View {
    let systemImage: String
    let action: () -> Void
    
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}

// MARK: - MenuBar View
struct MenuBarView: View {
    // MARK: Properties
    var onNewNote: () -> Void
    var onUndo: () -> Void
    var onRedo: () -> Void
    var onExport: () -> Void
    var onToggleSidebar: () -> Void
    
    @Binding var editMode: EditMode

    // MARK: View Components
    private var fileButtons: some View {
        HStack {
            MenuBarButton(systemImage: "doc.badge.plus", action: onNewNote)
            MenuBarButton(systemImage: "square.and.arrow.up", action: onExport)
        }
    }
    
    private var editModeButton: some View {
        MenuBarButton(
            systemImage: editMode == .draw ? "pencil" : "hand.draw",
            action: { editMode = editMode == .draw ? .panSelect : .draw }
        )
    }
    
    private var historyButtons: some View {
        HStack {
            MenuBarButton(systemImage: "arrow.uturn.backward", action: onUndo)
            MenuBarButton(systemImage: "arrow.uturn.forward", action: onRedo)
        }
    }
    
    private var sidebarButton: some View {
            MenuBarButton(
                systemImage: "sidebar.right",
                action: onToggleSidebar
            )
        }
    
    // MARK: Body
    var body: some View {
        HStack {
            fileButtons
            Spacer()
            
            editModeButton
            historyButtons
            sidebarButton  
        }
        .padding()
        .background(Color.black.opacity(0.9))
    }
}

// MARK: - Preview
#Preview {
    MenuBarView(
        onNewNote: {},
        onUndo: {},
        onRedo: {},
        onExport: {},
        onToggleSidebar: {},
        editMode: .constant(.draw)
    )
}
