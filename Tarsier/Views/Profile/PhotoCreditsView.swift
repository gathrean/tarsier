import SwiftUI

struct PhotoCreditsView: View {
    private var credits: [ImageCredit] {
        LessonService.shared.loadAllLessons()
            .flatMap { lesson in
                lesson.slides.compactMap { slide -> ImageCredit? in
                    guard let image = slide.image,
                          let attribution = image.attribution,
                          !attribution.isEmpty else { return nil }
                    return ImageCredit(
                        lessonTitle: lesson.title,
                        attribution: attribution,
                        licence: image.licence ?? "Unknown",
                        source: image.source ?? ""
                    )
                }
            }
    }

    var body: some View {
        List {
            if credits.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 36, weight: .semibold, design: .rounded))
                            .foregroundStyle(TarsierColors.textSecondary)

                        Text("No photo credits yet")
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textSecondary)

                        Text("Photo attributions will appear here as lessons are added.")
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .listRowBackground(TarsierColors.cream)
            } else {
                Section {
                    Text("Images used in lessons are sourced from Wikimedia Commons and other open-license providers.")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                }
                .listRowBackground(TarsierColors.cream)

                Section {
                    ForEach(credits) { credit in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(credit.attribution)
                                .font(TarsierFonts.body(15))
                                .foregroundStyle(TarsierColors.textPrimary)

                            HStack(spacing: 8) {
                                Text(credit.licence)
                                    .font(TarsierFonts.caption(11))
                                    .foregroundStyle(TarsierColors.functionalPurple)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule().fill(TarsierColors.brandPurple.opacity(0.15))
                                    )

                                Text(credit.lessonTitle)
                                    .font(TarsierFonts.caption(11))
                                    .foregroundStyle(TarsierColors.textSecondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(TarsierColors.cream)
            }
        }
        .scrollContentBackground(.hidden)
        .background(TarsierColors.warmWhite)
        .navigationTitle("Photo Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Image Credit

private struct ImageCredit: Identifiable {
    let lessonTitle: String
    let attribution: String
    let licence: String
    let source: String

    var id: String { "\(lessonTitle)_\(attribution)" }
}
