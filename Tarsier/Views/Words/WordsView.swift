import SwiftUI
import SwiftData

struct WordsView: View {
    @Query(sort: \WordBankEntry.word) private var words: [WordBankEntry]
    @State private var searchText = ""
    @State private var selectedChapter = "All"
    @State private var expandedWordID: UUID?
    @State private var chapters: [Chapter] = []

    private var filteredWords: [WordBankEntry] {
        var result = words

        if selectedChapter != "All" {
            result = result.filter { $0.chapterId == selectedChapter }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.word.lowercased().contains(query)
                || $0.meaning.lowercased().contains(query)
                || $0.root.lowercased().contains(query)
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            if words.isEmpty {
                emptyState
            } else {
                wordList
            }
        }
        .background(TarsierColors.warmWhite)
        .navigationTitle("Words")
        .onAppear {
            chapters = LessonService.shared.loadChapters()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundStyle(TarsierColors.brandPurple)

            VStack(spacing: 8) {
                Text("Vocab")
                    .font(TarsierFonts.title())
                    .foregroundStyle(TarsierColors.textPrimary)

                Text("Start your first lesson to build your vocab")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Word List

    private var wordList: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(TarsierColors.textSecondary)
                TextField("Search words...", text: $searchText)
                    .font(TarsierFonts.body())

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }
            }
            .padding(TarsierSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .fill(TarsierColors.cream)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
            )
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Chapter filter pills
            chapterFilterPills
                .padding(.bottom, 8)

            // Word count
            HStack {
                Text("\(filteredWords.count) word\(filteredWords.count == 1 ? "" : "s") learned")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                Spacer()
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .padding(.bottom, 8)

            // Word cards
            ScrollView {
                LazyVStack(spacing: TarsierSpacing.itemSpacing) {
                    ForEach(filteredWords, id: \.id) { entry in
                        WordCard(
                            entry: entry,
                            isExpanded: expandedWordID == entry.id,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    expandedWordID = expandedWordID == entry.id ? nil : entry.id
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, TarsierSpacing.screenPadding)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Chapter Filter Pills

    private var chapterFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(title: "All", isActive: selectedChapter == "All") {
                    selectedChapter = "All"
                }

                ForEach(chapters) { chapter in
                    FilterPill(
                        title: chapter.title,
                        isActive: selectedChapter == chapter.id
                    ) {
                        selectedChapter = chapter.id
                    }
                }
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)
        }
    }
}

// MARK: - Filter Pill

private struct FilterPill: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TarsierFonts.caption())
                .foregroundStyle(isActive ? .white : TarsierColors.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isActive ? TarsierColors.functionalPurple : TarsierColors.cream)
                )
                .overlay(
                    Capsule()
                        .stroke(isActive ? .clear : TarsierColors.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Word Card

private struct WordCard: View {
    let entry: WordBankEntry
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Collapsed row
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.word)
                            .font(TarsierFonts.tagalogWord(18))
                            .foregroundStyle(TarsierColors.textPrimary)
                        Text(entry.meaning)
                            .font(TarsierFonts.body(14))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }

                    Spacer()

                    if let affix = entry.affix, !affix.isEmpty {
                        Text(affix)
                            .font(TarsierFonts.caption(11))
                            .foregroundStyle(TarsierColors.functionalPurple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(TarsierColors.brandPurple.opacity(0.15))
                            )
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            }
            .buttonStyle(.plain)

            // Expanded details
            if isExpanded {
                expandedContent
            }
        }
        .padding(TarsierSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .fill(TarsierColors.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .stroke(isExpanded ? TarsierColors.functionalPurple : TarsierColors.cardBorder, lineWidth: isExpanded ? 2 : 1)
        )
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.vertical, 4)

            // Pronunciation
            if let pronunciation = entry.pronunciationGuide, !pronunciation.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(TarsierColors.textSecondary)
                    Text(pronunciation)
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                        .italic()
                }
            }

            // Root
            HStack(spacing: 6) {
                Text("Root:")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                Text(entry.root)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textPrimary)
            }

            // Example sentence
            if let example = entry.exampleSentence, !example.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(example)
                        .font(TarsierFonts.body(15))
                        .fontWeight(.semibold)
                        .foregroundStyle(TarsierColors.textPrimary)

                    if let translation = entry.exampleTranslation, !translation.isEmpty {
                        Text(translation)
                            .font(TarsierFonts.body(14))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(TarsierColors.warmWhite)
                )
            }

            // Taglish variant
            if let taglish = entry.taglishVariant, !taglish.isEmpty {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(TarsierColors.functionalPurple)
                        .frame(width: 3)

                    Text("Taglish: \(taglish)")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                        .padding(.leading, 10)
                        .padding(.vertical, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(TarsierColors.warmWhite)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
