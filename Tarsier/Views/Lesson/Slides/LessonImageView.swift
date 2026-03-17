import SwiftUI

/// Shared image component for lesson content. Displays the image if it exists
/// in the bundle, or a grey placeholder with the image key if it doesn't.
/// If imageName is nil, renders nothing.
struct LessonImageView: View {
    let imageName: String?
    var cornerRadius: CGFloat = 12
    var aspectRatio: CGFloat = 3 / 2

    var body: some View {
        if let name = imageName, !name.isEmpty {
            let nameWithoutExt = (name as NSString).deletingPathExtension
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else if UIImage(named: nameWithoutExt) != nil {
                Image(nameWithoutExt)
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                // Placeholder
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemGray5))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .overlay(
                        Text(nameWithoutExt)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    )
            }
        }
        // If imageName is nil, render nothing
    }
}
