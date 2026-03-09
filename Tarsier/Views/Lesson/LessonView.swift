import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    @State private var isCulturalNoteExpanded = true
    @State private var revealedVocab: Set<String> = []
    @State private var showQuiz = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                culturalNoteSection
                etymologySection
                vocabularySection
                sentencesSection
                quizButton
            }
            .padding()
        }
        .navigationTitle(lesson.topic)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showQuiz) {
            QuizView(lesson: lesson)
        }
    }

    // MARK: - Cultural Note

    private var culturalNoteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation { isCulturalNoteExpanded.toggle() }
            } label: {
                HStack {
                    Label("Cultural Note", systemImage: "globe.asia.australia.fill")
                        .font(TarsierTheme.headline)
                        .foregroundStyle(TarsierTheme.brown)
                    Spacer()
                    Image(systemName: isCulturalNoteExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isCulturalNoteExpanded {
                Text(lesson.culturalNote)
                    .font(TarsierTheme.body)
                    .foregroundStyle(.secondary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TarsierTheme.cream)
                    )
            }
        }
    }

    // MARK: - Etymology

    private var etymologySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Word Roots & Patterns", systemImage: "tree.fill")
                .font(TarsierTheme.headline)
                .foregroundStyle(TarsierTheme.blue)

            Text(lesson.etymology.focus)
                .font(TarsierTheme.title3)

            Text(lesson.etymology.explanation)
                .font(TarsierTheme.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                Text("Pattern: ")
                    .font(TarsierTheme.callout)
                    .foregroundStyle(.secondary)
                Text(lesson.etymology.pattern)
                    .font(TarsierTheme.callout)
                    .bold()
                    .foregroundStyle(TarsierTheme.blue)
            }

            ForEach(lesson.etymology.examples) { example in
                HStack {
                    Text(example.root)
                        .font(TarsierTheme.body)
                        .foregroundStyle(.secondary)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(example.derived)
                        .font(TarsierTheme.headline)
                        .foregroundStyle(TarsierTheme.blue)
                    Text("(\(example.meaning))")
                        .font(TarsierTheme.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        )
    }

    // MARK: - Vocabulary

    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Vocabulary", systemImage: "character.book.closed.fill")
                .font(TarsierTheme.headline)

            ForEach(lesson.vocabulary) { vocab in
                VocabularyCard(
                    vocab: vocab,
                    isRevealed: revealedVocab.contains(vocab.id)
                ) {
                    if revealedVocab.contains(vocab.id) {
                        revealedVocab.remove(vocab.id)
                    } else {
                        revealedVocab.insert(vocab.id)
                    }
                }
            }
        }
    }

    // MARK: - Sentences

    private var sentencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Example Sentences", systemImage: "text.quote")
                .font(TarsierTheme.headline)

            ForEach(lesson.sentences) { sentence in
                VStack(alignment: .leading, spacing: 6) {
                    Text(sentence.tagalog)
                        .font(TarsierTheme.headline)
                        .foregroundStyle(TarsierTheme.blue)

                    Text(sentence.english)
                        .font(TarsierTheme.body)

                    Text(sentence.breakdown)
                        .font(TarsierTheme.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }

    // MARK: - Quiz Button

    private var quizButton: some View {
        Button {
            showQuiz = true
        } label: {
            Label("Start Quiz", systemImage: "pencil.and.list.clipboard")
                .font(TarsierTheme.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(TarsierTheme.blue)
        .padding(.top, 8)
    }
}

// MARK: - Vocabulary Card

struct VocabularyCard: View {
    let vocab: VocabularyItem
    let isRevealed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(vocab.tagalog)
                        .font(TarsierTheme.title3)
                        .foregroundStyle(TarsierTheme.blue)
                    Spacer()
                    Text("tap to reveal")
                        .font(TarsierTheme.caption)
                        .foregroundStyle(.tertiary)
                        .opacity(isRevealed ? 0 : 1)
                }

                if isRevealed {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vocab.english)
                            .font(TarsierTheme.body)
                        Text(vocab.pronunciation)
                            .font(TarsierTheme.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                        Divider()
                        Text(vocab.exampleSentence)
                            .font(TarsierTheme.callout)
                            .foregroundStyle(TarsierTheme.brown)
                        Text(vocab.exampleTranslation)
                            .font(TarsierTheme.caption)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isRevealed ? TarsierTheme.cream : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: isRevealed)
    }
}
