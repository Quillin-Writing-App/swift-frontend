import SwiftUI
import Ink
import WebKit

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    private var parent: HTMLView
    @Binding private var dynamicHeight: CGFloat
    
    init(_ parent: HTMLView, dynamicHeight: Binding<CGFloat>) {
        self.parent = parent
        self._dynamicHeight = dynamicHeight
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight") { height, _ in
            if let height = height as? CGFloat {
                self.dynamicHeight = height
            }
        }
    }
}

struct HTMLView: UIViewRepresentable {
    let html: String
    @Binding var dynamicHeight: CGFloat
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self, dynamicHeight: $dynamicHeight)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let config = """
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- MathJax Configuration -->
        <script>
          window.MathJax = {
            tex: {
              inlineMath: [['$', '$'], ['\\(', '\\)']],
              displayMath: [['$$', '$$'], ['\\[', '\\]']]
            },
            options: {
              skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
            }
          };
        </script>
        <!-- Load MathJax -->
        <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
        <style>
            body {
                margin: 0;
                padding: 8px;
                color: white;
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
                        
                        MessageView(html: html)
                            .background(Color(red: 0.07, green: 0.07, blue: 0.07))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

struct MessageView: View {
    let html: String
    @State private var dynamicHeight: CGFloat = 50  // Initial height
    
    var body: some View {
        HTMLView(html: html, dynamicHeight: $dynamicHeight)
            .frame(height: dynamicHeight)
    }
}

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(20)
            .background(Color(red: 0.25, green: 0.25, blue: 0.25))
            .cornerRadius(20)
            .foregroundColor(Color.white)
            .font(.system(size: 20))
    }
}



struct SidebarView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var uploadError: String? = nil
    @State private var explanation: String? = nil
    @Binding var messages: [String]  // Bind messages array so it can be updated
    @Binding var three: [String]
    
    private let imageService = ImageUploadService();
    
    func performAction( value: String ) {
        uploadText(value);
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Hey Otto!")
                  .font(Font.custom("Inter", size: 30).weight(.light))
                  .foregroundColor(Color(red: 0.94, green: 0.94, blue: 0.92))
                  .padding(.top, 30)
                  .padding(.leading, 20)
                Spacer()
            }
            .padding()
            .background(Color(red: 0.07, green: 0.07, blue: 0.07))
            
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 400, height: 1)
              .background(Color(red: 0.94, green: 0.94, blue: 0.92))
              .overlay(Rectangle()
                .stroke(.black, lineWidth: 0.50))


            // Chat content
            MarkdownMessagesView(messages: messages)
            
            Button(action: {
                performAction(value: three[0]) // Call the function when text is pressed
                    }) {
                        Text(three[0]) // Display each string
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
            
            Divider()
                .frame(height: 1) // Customize the thickness of the line
                .background(Color.gray) // Customize the color of the line
            Button(action: {
                        performAction(value: three[1]) // Call the function when text is pressed
                    }) {
                        Text(three[1]) // Display each string
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                
            Divider()
                .frame(height: 1) // Customize the thickness of the line
                .background(Color.gray) // Customize the color of the line
                .padding(.horizontal)

            Button(action: {
                        performAction(value: three[2]) // Call the function when text is pressed
                    }) {
                        Text(three[2]) // Display each string
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
            
            Divider()
                .frame(height: 1) // Customize the thickness of the line
                .background(Color.gray) // Customize the color of the line
                .padding(.horizontal)


            
            // Input area
            VStack(spacing: 8) {
                Divider()
                ZStack (alignment: .leading) {
                    if messageText.isEmpty {
                        Text("Type a message...")
                            .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.67))
                            .font(.system(size: 20))
                            .padding(.leading, 35)
                    }
                    TextField("", text: $messageText)
                        .foregroundColor(Color(red: 0.94, green: 0.94, blue: 0.92))
                        .font(.system(size: 20))
                        .padding(.leading, 35)

                    
                          // Increases the input text size
                    
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
                .background(Color(red: 0.07, green: 0.07, blue: 0.07))
                .padding([.horizontal, .bottom])
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        }
        .frame(width: 450) //FIXED WIDTH MAY REQUIRE CHANGE
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
    
    private func uploadText(_ text: String) {
            isLoading = true
            Task {
                do {
                    let response = try await imageService.uploadText(text)
                    await MainActor.run {
                        isLoading = false
                        explanation = response.explanation
                        messages.append("Assistant: " + response.explanation)
                        
                        three = []
                        three.append(response.clarifying_prompts[0])
                        three.append(response.clarifying_prompts[1])
                        three.append(response.clarifying_prompts[2])
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        uploadError = error.localizedDescription
                    }
                }
            }
        }
    
    private func sendMessage() {
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        // Add user message to chat
        //messages.append("You: " + message)
        
        // Clear input field
        messageText = ""
        isLoading = true
        
        // Send message using ChatService
        Task {
//            do {
//                //let response = try await chatService.sendMessage(message)
//                // Update UI on main thread
//                await MainActor.run {
//                    //messages.append("Assistant: " + response)
//                    isLoading = false
//                }
//            } catch {
//                await MainActor.run {
//                    //messages.append("Error: Failed to send message")
//                    isLoading = false
//                }
//                print("Error sending message: \(error)")
//            }
        }
    }
}

//#Preview {
//    SidebarView(messages: ["dfsf"])
//}
