import Foundation

struct AIChatMessage: Codable, Identifiable {
    var id = UUID()
    let role: String // "user" or "model"
    let content: String
    var timestamp = Date()
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
}

struct AIInsight: Codable, Identifiable {
    var id: String { title }
    let title: String
    let description: String
    let type: String // "positive", "negative", "warning"
}

struct AIAnalysis: Codable {
    let financialScore: Int
    let summary: String
    let savingsRateComment: String
    let insights: [AIInsight]
    let recommendations: [String]
}
