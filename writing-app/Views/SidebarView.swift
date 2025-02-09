import SwiftUI

struct SidebarView: View {
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Chat")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Chat content will go here
            ScrollView {
                VStack {
                    Text("No messages yet")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Input area
            VStack(spacing: 8) {
                Divider()
                HStack {
                    TextField("Type a message...", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        // Send message action
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .frame(width: 300)
        .background(Color(.systemBackground))
    }
}
#Preview {
    SidebarView()
}
