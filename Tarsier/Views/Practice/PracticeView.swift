import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.createdAt) private var allMessages: [ChatMessage]
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    // Filter to today's session
    private var messages: [ChatMessage] {
        let today = Calendar.current.startOfDay(for: Date())
        return allMessages.filter { $0.sessionDate == today }
    }

    private var todayMessageCount: Int {
        messages.filter(\.isUser).count
    }

    private let dailyLimit = 30

    var body: some View {
        VStack(spacing: 0) {
            if messages.isEmpty {
                emptyState
            } else {
                messageList
            }
            inputBar
        }
        .navigationTitle("Practice with Tarsier")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "eyes")
                .font(.system(size: 50))
                .foregroundStyle(TarsierTheme.brown)

            Text("Ask Tarsier anything!")
                .font(TarsierTheme.title3)

            Text("Try: \"How do I ask my tita if she's eaten yet?\"")
                .font(TarsierFonts.body(15))
                .foregroundStyle(TarsierColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if isLoading {
                        HStack {
                            ProgressView()
                                .padding(.horizontal)
                            Text("Tarsier is thinking...")
                                .font(TarsierTheme.caption)
                                .foregroundStyle(TarsierColors.textSecondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) {
                if let last = messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()

            if let error = errorMessage {
                Text(error)
                    .font(TarsierTheme.caption)
                    .foregroundStyle(TarsierTheme.red)
                    .padding(.horizontal)
                    .padding(.top, 6)
            }

            HStack(spacing: 10) {
                TextField("Ask in English or Tagalog...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .font(TarsierTheme.body)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(canSend ? TarsierColors.functionalPurple : TarsierColors.cardBorder)
                }
                .disabled(!canSend)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading && todayMessageCount < dailyLimit
    }

    // MARK: - Send

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(content: text, isUser: true)
        modelContext.insert(userMessage)
        inputText = ""
        errorMessage = nil
        isLoading = true

        Task {
            do {
                let history = messages.map { (content: $0.content, isUser: $0.isUser) }
                let response = try await TarsierAIService.shared.sendMessage(text, history: history)
                let aiMessage = ChatMessage(content: response, isUser: false)
                modelContext.insert(aiMessage)
            } catch {
                errorMessage = "Tarsier is sleeping right now. Try again in a moment!"
            }
            isLoading = false
        }
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(TarsierTheme.body)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isUser ? TarsierTheme.blue : TarsierTheme.cream)
                    )
                    .foregroundStyle(message.isUser ? .white : TarsierColors.textPrimary)
            }

            if !message.isUser { Spacer(minLength: 60) }
        }
    }
}
