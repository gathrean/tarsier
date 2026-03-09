import SwiftUI

struct AlamMoBaSlideView: View {
    let slide: LessonSlide

    var body: some View {
        VStack {
            Spacer()
            AlamMoBaView(text: slide.body ?? "")
            Spacer()
        }
    }
}
