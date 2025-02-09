import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - MenuBar Button
struct MenuBarButton: View {
    let systemImage: String
    let action: () -> Void
    let toggled: Bool  // Only applies to certain buttons

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundColor(toggled ? Color(UIColor(hex: "#FFFAFA")) : Color(UIColor(hex: "#F1EFEC")))
                // Set to #FFFAFA when toggled, #F1EFEC by default
                .font(.system(size: 20)) // Reduced font size to 20
        }
        .padding(.horizontal)
    }
}

// MARK: - MenuBar View
struct MenuBarView: View {
    // MARK: Properties
    var returnHome: () -> Void
    var onNewNote: () -> Void
    var onUndo: () -> Void
    var onRedo: () -> Void
    var onExport: () -> Void
    var onToggleSidebar: () -> Void

    @ObservedObject var drawingState: DrawingState

    // MARK: View Components
    
    private var homeButton: some View {
        HStack {
            MenuBarButton(systemImage: "house", action: returnHome, toggled: false) // Always white
        }
    }
    
    private var historyButtons: some View {
        HStack {
            MenuBarButton(systemImage: "arrow.uturn.backward", action: onUndo, toggled: false) // Always white
            MenuBarButton(systemImage: "arrow.uturn.forward", action: onRedo, toggled: false) // Always white
        }
    }
    
    private var fileButtons: some View {
        HStack {
            MenuBarButton(systemImage: "doc.badge.plus", action: onNewNote, toggled: false) // Always white
            MenuBarButton(systemImage: "square.and.arrow.up", action: onExport, toggled: false) // Always white
        }
    }

    private var writeModeButton: some View {
        MenuBarButton(
            systemImage: "pencil",
            action: { drawingState.editMode = .draw },
            toggled: drawingState.editMode == .draw
        )
    }

    private var eraserModeButton: some View {
        MenuBarButton(
            systemImage: "eraser",
            action: { drawingState.editMode = .erase },
            toggled: drawingState.editMode == .erase
        )
    }

    private var lassoModeButton: some View {
        MenuBarButton(
            systemImage: "lasso",
            action: { drawingState.editMode = .panSelect },
            toggled: drawingState.editMode == .panSelect
        )
    }
    private var sidebarButton: some View {
                MenuBarButton(
                    systemImage: "sidebar.right",
                    action: onToggleSidebar,
                    toggled: false
                )
            }
    // MARK: Body
    var body: some View {
        HStack {
            homeButton
            historyButtons
            
            Spacer()

            writeModeButton
            eraserModeButton
            lassoModeButton
            
            Spacer()
            
            fileButtons
            sidebarButton
        }
        .padding()
        .background(Color(UIColor(red: 0x3F / 255, green: 0x3F / 255, blue: 0x3F / 255, alpha: 1.0)))
    }
}

// MARK: - Preview
//#Preview {
//    MenuBarView(
//        returnHome: {},
//        onNewNote: {},
//        onUndo: {},
//        onRedo: {},
//        onExport: {},
//        onToggleSidebar: {},
//        editMode: .constant(.draw)
//    )
//}
