import SwiftUI
import SwiftData

struct NotificationPermissionView: View {
    let onComplete: () -> Void

    @Query private var profiles: [UserProfile]
    @State private var selectedTime: Date = {
        var components = DateComponents()
        components.hour = 19
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "eyes")
                .font(.system(size: 48))
                .foregroundStyle(TarsierColors.tarsierDark)

            Text("Want Tarsier to remind you to practice?")
                .font(TarsierFonts.title(24))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Pick a time that works for you")
                .font(TarsierFonts.body())
                .foregroundStyle(TarsierColors.textSecondary)

            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 150)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton("Remind me") {
                    profile?.notificationTime = selectedTime
                    Task {
                        await NotificationService.requestAndSchedule(
                            at: selectedTime,
                            userName: profile?.userName
                        )
                    }
                    onComplete()
                }

                Button {
                    onComplete()
                } label: {
                    Text("Not now")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .background(TarsierColors.warmWhite.ignoresSafeArea())
    }
}
