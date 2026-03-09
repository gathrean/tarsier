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
            .padding(TarsierSpacing.screenPadding)
        }
        .background(TarsierColors.warmWhite)
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
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            }
            .buttonStyle(.plain)

            if isCulturalNoteExpanded {
                Text(lesson.culturalNote)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .padding(TarsierSpacing.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .fill(TarsierColors.cream)
                    )
            }
        }
    }

    // MARK: - Etymology

    private var etymologySection: some View {
        TarsierCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Word Roots & Patterns", systemImage: "tree.fill")
                    .font(TarsierTheme.headline)
                    .foregroundStyle(TarsierTheme.blue)

                Text(lesson.etymology.focus)
                    .font(TarsierTheme.title3)

                Text(lesson.etymology.explanation)
                    .font(TarsierTheme.body)
                    .foregroundStyle(TarsierColors.textSecondary)

                HStack(spacing: 0) {
                    Text("Pattern: ")
                        .font(TarsierTheme.callout)
                        .foregroundStyle(TarsierColors.textSecondary)
                    Text(lesson.etymology.pattern)
                        .font(TarsierTheme.callout)
                        .bold()
                        .foregroundStyle(TarsierTheme.blue)
                }

                ForEach(lesson.etymology.examples) { example in
                    HStack {
                        Text(example.root)
                            .font(TarsierTheme.body)
                            .foregroundStyle(TarsierColors.textSecondary)
                        Image(systemName: "arrow.right")
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.textSecondary)
                        Text(example.derived)
                            .font(TarsierTheme.headline)
                            .foregroundStyle(TarsierTheme.blue)
                        Text("(\(example.meaning))")
                            .font(TarsierTheme.caption)
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }
            }
        }
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
                TarsierCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(sentence.tagalog)
                            .font(TarsierTheme.headline)
                            .foregroundStyle(TarsierTheme.blue)

                        Text(sentence.english)
                            .font(TarsierTheme.body)

                        Text(sentence.breakdown)
                            .font(TarsierTheme.caption)
                            .foregroundStyle(TarsierColors.textSecondary)
                            .italic()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Quiz Button

    private var quizButton: some View {
        PrimaryButton("Start Quiz", icon: "pencil.and.list.clipboard") {
            showQuiz = true
        }
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
                        .foregroundStyle(TarsierColors.textSecondary.opacity(0.6))
                        .opacity(isRevealed ? 0 : 1)
                }

                if isRevealed {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vocab.english)
                            .font(TarsierTheme.body)
                        Text(vocab.pronunciation)
                            .font(TarsierTheme.caption)
                            .foregroundStyle(TarsierColors.textSecondary)
                            .italic()
                        Divider()
                        Text(vocab.exampleSentence)
                            .font(TarsierTheme.callout)
                            .foregroundStyle(TarsierTheme.brown)
                        Text(vocab.exampleTranslation)
                            .font(TarsierTheme.caption)
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(TarsierSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .fill(TarsierColors.cream)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .stroke(isRevealed ? TarsierColors.functionalPurple : TarsierColors.cardBorder, lineWidth: isRevealed ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: isRevealed)
    }
}
