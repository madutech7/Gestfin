import SwiftUI

struct CoachView: View {
    @StateObject private var viewModel = CoachViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @Environment(\.colorScheme) var colorScheme
    
    let suggestions = [
        "Comment optimiser mes économies ?",
        "Réduire le budget alimentation",
        "Analyser un projet d'achat"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gemini Style (Clean)
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Ambient Blurs simulating Gemini glow
                GeometryReader { geo in
                    Circle()
                        .fill(Color.appBlue.opacity(0.06))
                        .frame(width: geo.size.width, height: geo.size.width)
                        .offset(x: -geo.size.width * 0.2, y: -geo.size.width * 0.4)
                        .blur(radius: 80)
                    
                    Circle()
                        .fill(Color.appCyan.opacity(0.06))
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.6)
                        .blur(radius: 80)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    chatTab
                }
            }
            .navigationTitle("SamaCoach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        viewModel.clearChat()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Chat Tab
    
    private var chatTab: some View {
        VStack(spacing: 0) {
            // Message List
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 28) {
                        ForEach(viewModel.chatMessages) { msg in
                            ChatBubble(message: msg)
                        }
                        
                        if viewModel.isSendingMessage {
                            TypingIndicator()
                        }
                    }
                    .padding(.vertical, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.chatMessages.count) { _, _ in
                    if let last = viewModel.chatMessages.last {
                        withAnimation {
                            scrollProxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Suggestion horizontal row
            if viewModel.chatMessages.count <= 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(suggestions, id: \.self) { sug in
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.sendMessage(sug)
                            } label: {
                                Text(sug)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .foregroundColor(.primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
            }
            
            // Input Row (Gemini Style)
            HStack(alignment: .bottom, spacing: 8) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
                
                HStack(alignment: .bottom, spacing: 0) {
                    TextField("Demandez à SamaCoach...", text: $viewModel.inputText, axis: .vertical)
                        .lineLimit(1...8)
                        .submitLabel(.send)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .onSubmit {
                            if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                viewModel.sendMessage()
                                hideKeyboard()
                            }
                        }
                    
                    if viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            if speechRecognizer.isRecording {
                                speechRecognizer.stopTranscribing()
                                viewModel.inputText = speechRecognizer.transcript
                            } else {
                                speechRecognizer.transcript = ""
                                speechRecognizer.startTranscribing()
                            }
                        } label: {
                            Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.fill")
                                .font(.system(size: 22))
                                .foregroundColor(speechRecognizer.isRecording ? .red : .primary)
                                .padding(.trailing, 16)
                                .padding(.bottom, 12)
                                .scaleEffect(speechRecognizer.isRecording ? 1.2 : 1.0)
                        }
                        .onChange(of: speechRecognizer.transcript) { _, newValue in
                            if speechRecognizer.isRecording {
                                viewModel.inputText = newValue
                            }
                        }
                    } else {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            viewModel.sendMessage()
                            hideKeyboard()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.primary)
                                .padding(.trailing, 6)
                                .padding(.bottom, 6)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.inputText)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground))
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EditChatMessage"))) { notification in
            if let msg = notification.object as? AIChatMessage {
                viewModel.editMessage(msg)
            }
        }
        .onDisappear {
            if speechRecognizer.isRecording {
                speechRecognizer.stopTranscribing()
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Subviews

struct ChatBubble: View {
    let message: AIChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if message.role == "user" {
                HStack {
                    Spacer(minLength: 40)
                    Text(message.content)
                        .font(.system(.body))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .contextMenu {
                            Button {
                                NotificationCenter.default.post(name: NSNotification.Name("EditChatMessage"), object: message)
                            } label: {
                                Label("Modifier la question", systemImage: "pencil")
                            }
                        }
                }
                .padding(.horizontal, 20)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(.appBlue)
                        .padding(.top, 2)
                        
                    Text(message.content)
                        .font(.system(.body))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .id(message.id)
    }
}

struct TypingIndicator: View {
    @State private var pulse = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(.appBlue)
                .rotationEffect(Angle(degrees: pulse ? 15 : -15))
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.appBlue.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .scaleEffect(pulse ? 1.0 : 0.6)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: pulse
                        )
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear { pulse = true }
    }
}
