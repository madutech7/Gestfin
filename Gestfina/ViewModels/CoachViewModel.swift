import Foundation
import SwiftUI
import Combine

class CoachViewModel: ObservableObject {
    @Published var isFetchingAnalysis = false
    @Published var isSendingMessage = false
    @Published var analysis: AIAnalysis? = nil
    @Published var chatMessages: [AIChatMessage] = []
    @Published var errorMessage: String? = nil
    @Published var inputText: String = ""
    
    init() {
        loadLocalAnalysis()
        loadLocalChat()
    }
    
    func fetchAnalysis() {
        isFetchingAnalysis = true
        errorMessage = nil
        
        APIManager.shared.fetchAIAnalysis { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetchingAnalysis = false
                switch result {
                case .success(let data):
                    self?.analysis = data
                    self?.saveLocalAnalysis(data)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func sendMessage(_ text: String? = nil) {
        let messageToSend = (text ?? inputText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageToSend.isEmpty else { return }
        
        if text == nil {
            inputText = ""
        }
        
        let userMessage = AIChatMessage(role: "user", content: messageToSend)
        chatMessages.append(userMessage)
        saveLocalChat()
        
        isSendingMessage = true
        errorMessage = nil
        
        APIManager.shared.sendAIChatMessage(message: messageToSend, history: chatMessages.dropLast()) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSendingMessage = false
                switch result {
                case .success(let reply):
                    let modelMessage = AIChatMessage(role: "model", content: reply)
                    self?.chatMessages.append(modelMessage)
                    self?.saveLocalChat()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func clearChat() {
        chatMessages = [
            AIChatMessage(role: "model", content: "Bonjour ! Je suis SamaCoach, votre assistant financier intelligent. Posez-moi vos questions sur votre budget, vos dépenses ou vos stratégies d'épargne !")
        ]
        saveLocalChat()
    }
    
    func editMessage(_ message: AIChatMessage) {
        guard message.role == "user",
              let index = chatMessages.firstIndex(where: { $0.id == message.id }) else { return }
        
        // Remettre le texte dans le TextField
        inputText = message.content
        
        // Supprimer ce message et tout ce qui a suivi
        chatMessages = Array(chatMessages.prefix(index))
        saveLocalChat()
    }
    
    // MARK: - Cache local pour un accès instantané hors-ligne
    
    private func saveLocalAnalysis(_ data: AIAnalysis) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "gestfina_ai_analysis")
        }
    }
    
    private func loadLocalAnalysis() {
        if let data = UserDefaults.standard.data(forKey: "gestfina_ai_analysis"),
           let decoded = try? JSONDecoder().decode(AIAnalysis.self, from: data) {
            self.analysis = decoded
        }
    }
    
    private func saveLocalChat() {
        if let encoded = try? JSONEncoder().encode(chatMessages) {
            UserDefaults.standard.set(encoded, forKey: "gestfina_ai_chat_v2")
        }
    }
    
    private func loadLocalChat() {
        if let data = UserDefaults.standard.data(forKey: "gestfina_ai_chat_v2"),
           let decoded = try? JSONDecoder().decode([AIChatMessage].self, from: data) {
            self.chatMessages = decoded
        } else {
            self.chatMessages = [
                AIChatMessage(role: "model", content: "Bonjour ! Je suis SamaCoach, votre assistant financier intelligent. Posez-moi vos questions sur votre budget, vos dépenses ou vos stratégies d'épargne !")
            ]
        }
    }
}
