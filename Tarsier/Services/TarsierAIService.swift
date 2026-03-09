import Foundation
import GoogleGenerativeAI

final class TarsierAIService: @unchecked Sendable {
    nonisolated(unsafe) static let shared = TarsierAIService()

    private let model: GenerativeModel?

    private let systemPrompt = """
    You are Tarsier, a friendly Tagalog language tutor. The user is learning Tagalog.
    When they describe a situation or ask how to say something:
    1. Give the Tagalog phrase
    2. Give a pronunciation guide
    3. Break down the grammar (identify roots and affixes)
    4. Give a cultural context note if relevant
    5. Suggest a natural Taglish alternative if applicable
    Keep responses concise and warm. Use casual, encouraging tone.
    """

    private init() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
           !apiKey.isEmpty {
            model = GenerativeModel(
                name: "gemini-2.0-flash",
                apiKey: apiKey,
                systemInstruction: ModelContent(role: "system", parts: [.text(systemPrompt)])
            )
        } else {
            model = nil
        }
    }

    func sendMessage(_ message: String, history: [(content: String, isUser: Bool)]) async throws -> String {
        guard let model else {
            throw TarsierAIError.notConfigured
        }

        let historyContent = history.map { msg in
            ModelContent(
                role: msg.isUser ? "user" : "model",
                parts: [.text(msg.content)]
            )
        }

        let allContent = historyContent + [ModelContent(role: "user", parts: [.text(message)])]
        let response = try await model.generateContent(allContent)
        guard let text = response.text else {
            throw TarsierAIError.emptyResponse
        }
        return text
    }
}

enum TarsierAIError: LocalizedError {
    case notConfigured
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "Tarsier AI is not configured. Please add your Gemini API key."
        case .emptyResponse:
            "Tarsier is sleeping right now. Try again in a moment!"
        }
    }
}
