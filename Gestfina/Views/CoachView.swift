import SwiftUI

struct CoachView: View {
    @StateObject private var viewModel = CoachViewModel()
    @State private var selectedMode: CoachMode = .analysis
    @Environment(\.colorScheme) var colorScheme
    
    enum CoachMode {
        case analysis
        case chat
    }
    
    let suggestions = [
        "Comment optimiser mes économies ?",
        "Réduire le budget alimentation",
        "Analyser un projet d'achat"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Ambient Blurs
                GeometryReader { geo in
                    Circle()
                        .fill(Color.appBlue.opacity(0.15))
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .offset(x: -geo.size.width * 0.3, y: -geo.size.width * 0.2)
                        .blur(radius: 60)
                    
                    Circle()
                        .fill(Color.appCyan.opacity(0.12))
                        .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                        .offset(x: geo.size.width * 0.6, y: -geo.size.width * 0.1)
                        .blur(radius: 50)
                }
                
                VStack(spacing: 0) {
                    // Segmented Control Apple Style
                    HStack(spacing: 0) {
                        TabButton(title: "Prévisions", icon: "chart.pie.fill", isSelected: selectedMode == .analysis) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selectedMode = .analysis }
                        }
                        TabButton(title: "SamaCoach", icon: "waveform", isSelected: selectedMode == .chat) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selectedMode = .chat }
                        }
                    }
                    .padding(4)
                    .background(Color(UIColor.tertiarySystemGroupedBackground).opacity(0.8))
                    .clipShape(Capsule())
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
                    
                    Divider()
                    
                    if selectedMode == .analysis {
                        analysisTab
                    } else {
                        chatTab
                    }
                }
            }
            .navigationTitle("SamaCoach")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if selectedMode == .chat {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            viewModel.clearChat()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onAppear {
                if viewModel.analysis == nil {
                    viewModel.fetchAnalysis()
                }
            }
        }
    }
    
    // MARK: - Analysis Tab
    
    private var analysisTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                if viewModel.isFetchingAnalysis && viewModel.analysis == nil {
                    ProgressView("Analyse en cours...")
                        .frame(maxWidth: .infinity, minHeight: 250)
                } else if let analysis = viewModel.analysis {
                    // Score Card
                    VStack(spacing: 16) {
                        ScoreView(score: analysis.financialScore)
                            .padding(.top, 10)
                        
                        Text(analysis.summary)
                            .font(.system(size: 15, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 20)
                    
                    // Savings Rate Comment
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Épargne & Revenus", systemImage: "percent")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appBlue)
                        
                        Text(analysis.savingsRateComment)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 20)
                    
                    // Insights List
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Observations Clés")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 24)
                        
                        ForEach(analysis.insights) { insight in
                            InsightCard(insight: insight)
                        }
                    }
                    
                    // Recommendations List
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Actions Recommandées")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 24)
                        
                        ForEach(Array(analysis.recommendations.enumerated()), id: \.offset) { index, rec in
                            HStack(alignment: .top, spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.appBlue.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.appBlue)
                                }
                                
                                Text(rec)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineSpacing(3)
                                    .padding(.top, 6)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Refresh Button
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        viewModel.fetchAnalysis()
                    } label: {
                        HStack {
                            if viewModel.isFetchingAnalysis {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text("Recalculer les conseils")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.appBlue, Color.appCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.appBlue.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .disabled(viewModel.isFetchingAnalysis)
                    
                } else {
                    // Empty state/error
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                        Text(viewModel.errorMessage ?? "Impossible de charger l'analyse.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Réessayer") {
                            viewModel.fetchAnalysis()
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.appBlue)
                        .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                }
            }
            .padding(.top, 16)
        }
    }
    
    // MARK: - Chat Tab
    
    private var chatTab: some View {
        VStack(spacing: 0) {
            // Message List
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.chatMessages) { msg in
                            ChatBubble(message: msg)
                        }
                        
                        if viewModel.isSendingMessage {
                            TypingIndicator()
                        }
                    }
                    .padding(.vertical, 20)
                }
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
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .foregroundColor(.appBlue)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.appBlue.opacity(0.1), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
            }
            
            Divider()
            
            // Input Row Premium
            HStack(spacing: 12) {
                TextField("Demandez à Sama...", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .font(.system(size: 16))
                    .submitLabel(.send)
                    .onSubmit {
                        if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.sendMessage()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(colors: [.appCyan.opacity(0.5), .appBlue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.appBlue.opacity(0.15), radius: 10, y: 5)
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendMessage()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.appBlue, Color.appCyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: Color.appBlue.opacity(0.3), radius: 8, y: 4)
                        
                        Image(systemName: viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "mic.fill" : "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .disabled(viewModel.isSendingMessage)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.clear)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EditChatMessage"))) { notification in
            if let msg = notification.object as? AIChatMessage {
                viewModel.editMessage(msg)
            }
        }
    }
}

// MARK: - Subviews

struct ScoreView: View {
    let score: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.quaternaryLabel), lineWidth: 14)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(score) / 100.0, 1.0)))
                .stroke(
                    LinearGradient(
                        colors: scoreColors(score),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
            
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                Text("Santé financière")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 140, height: 140)
    }
    
    private func scoreColors(_ score: Int) -> [Color] {
        if score >= 75 {
            return [.appGreen, Color(hex: "#34C759")]
        } else if score >= 50 {
            return [.appOrange, Color(hex: "#FF9500")]
        } else {
            return [.appRed, Color(hex: "#FF3B30")]
        }
    }
}

struct InsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                Text(insight.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 20)
    }
    
    private var accentColor: Color {
        switch insight.type {
        case "positive": return .appGreen
        case "warning": return .appOrange
        case "negative": return .appRed
        default: return .appBlue
        }
    }
    
    private var iconName: String {
        switch insight.type {
        case "positive": return "checkmark.circle.fill"
        case "warning": return "exclamationmark.triangle.fill"
        case "negative": return "xmark.circle.fill"
        default: return "info.circle.fill"
        }
    }
}

struct ChatBubble: View {
    let message: AIChatMessage
    
    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer(minLength: 40)
                Text(message.content)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Color.appCyan, Color.appBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(BubbleShape(isUser: true))
                    .shadow(color: Color.appBlue.opacity(0.25), radius: 8, y: 4)
                    .contextMenu {
                        Button {
                            // Appel pour relancer / modifier cette question
                            NotificationCenter.default.post(name: NSNotification.Name("EditChatMessage"), object: message)
                        } label: {
                            Label("Modifier la question", systemImage: "pencil")
                        }
                    }
            } else {
                Text(message.content)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.secondarySystemGroupedBackground).opacity(0.9))
                    .background(.ultraThinMaterial)
                    .clipShape(BubbleShape(isUser: false))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 20)
        .id(message.id)
    }
}

struct BubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            automaticallyLoadedRoundedRect: rect,
            byRoundingCorners: isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}

extension UIBezierPath {
    convenience init(automaticallyLoadedRoundedRect rect: CGRect, byRoundingCorners corners: UIRectCorner, cornerRadii: CGSize) {
        self.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
    }
}

struct TypingIndicator: View {
    @State private var pulse = false
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulse ? 1.0 : 0.6)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: pulse
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(BubbleShape(isUser: false))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear { pulse = true }
    }
}
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(LinearGradient(colors: [Color.appBlue, Color.appCyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.appBlue.opacity(0.3), radius: 8, y: 4)
                    }
                }
            )
        }
    }
}
