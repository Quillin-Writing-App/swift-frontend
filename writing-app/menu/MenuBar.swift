import SwiftUI

struct MenuBarView: View {
    var body: some View {
        HStack {
            Button(action: { print("New document") }) {
                Image(systemName: "doc.badge.plus")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: { print("Undo") }) {
                Image(systemName: "arrow.uturn.backward")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Button(action: { print("Redo") }) {
                Image(systemName: "arrow.uturn.forward")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.black.opacity(0.9))
    }
}

#Preview {
    MenuBarView()
}
