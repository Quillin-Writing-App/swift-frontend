import SwiftUI
import Ink
import WebKit

struct HTMLView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
            // Add configuration to make content fill width
            let config = """
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    margin: 0;
                    padding: 8px;
                    height: 100%;
                    width: 100%;
                    box-sizing: border-box;
                    font-family: -apple-system, system-ui;
                }
                * {
                    max-width: 100%;
                }
            </style>
            """
            let fullHTML = "\(config)\(html)"
            uiView.loadHTMLString(fullHTML, baseURL: nil)
        }
}

struct MarkdownMessagesView: View {
    let messages: [String]
    
    let parser = MarkdownParser()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if messages.isEmpty {
                    Text("No messages yet")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(messages, id: \.self) { message in
                        let result = parser.parse(message)
                        let html = result.html
                        
                        HTMLView(html: html)
                            .frame(minHeight: 100)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            }
                        }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}
struct SidebarView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var messages: [String] = []
    @State private var isLoading = false
    
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
            
            // Chat content
            MarkdownMessagesView(messages: messages)
            
            // Input area
            VStack(spacing: 8) {
                Divider()
                HStack {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                    
                    Button(action: sendMessage) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                        }
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .frame(width: 300)
        .background(Color(.systemBackground))
    }
    
    private func sendMessage() {
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        // Add user message to chat
        messages.append("You: " + message)
        
        // Clear input field
        messageText = ""
        isLoading = true
        
        // Send message using ChatService
        Task {
            do {
                let response = try await chatService.sendMessage(message)
                // Update UI on main thread
                await MainActor.run {
                    messages.append("Assistant: " + response)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    messages.append("Error: Failed to send message")
                    isLoading = false
                }
                print("Error sending message: \(error)")
            }
        }
    }
}

#Preview {
    SidebarView()
}
