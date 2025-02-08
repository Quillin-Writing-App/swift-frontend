import SwiftUI

struct MenuBarView: View {
    var onNewNote: () -> Void
    var onUndo: () -> Void
    var onRedo: () -> Void
    var onExport: () -> Void
    @Binding var editMode: EditMode
    
    var body: some View {
        HStack {
            Button(action: onNewNote) {
                Image(systemName: "doc.badge.plus")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Button(action: onExport) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Spacer()
            
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

