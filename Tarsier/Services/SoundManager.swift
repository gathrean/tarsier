import AudioToolbox
import AVFoundation

/// Handles all UI sound effects (correct, incorrect, tap, page, progress, lesson_complete).
/// Separate from AudioPlayerService which handles pronunciation audio.
/// Uses `.ambient` audio category so sounds don't interrupt background music.
///
/// Falls back to iOS system sounds when custom .wav/.mp3 files aren't bundled yet.
/// Once you drop in the real audio files, they take priority automatically.
@MainActor
final class SoundManager {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]

    /// System sound fallbacks — used when no custom .wav/.mp3 is bundled
    private let systemSoundFallbacks: [String: SystemSoundID] = [
        "correct":         1025,  // Fanfare.caf
        "incorrect":       1073,  // ct-error.caf
        "tap":             1104,  // Tock.caf
        "page":            1104,  // Tock.caf (no good whoosh in system sounds)
        "progress":        1025,  // Fanfare.caf
        "lesson_complete": 1025,  // Fanfare.caf
    ]

    /// Reads the user's sound preference from UserDefaults (matches @AppStorage("soundEnabled") in ProfileView)
    private var isMuted: Bool {
        !UserDefaults.standard.bool(forKey: "soundEnabled")
    }

    private init() {
        // Ensure the key defaults to true (sound on) if never set
        if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "soundEnabled")
        }

        configureAudioSession()
        preload(sounds: [
            "correct", "incorrect", "tap",
            "page", "progress", "lesson_complete"
        ])
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        } catch {
            // Non-fatal — sounds will still play but may interrupt music
        }
    }

    func preload(sounds: [String]) {
        for name in sounds {
            // Try .wav first, then .mp3
            let url = Bundle.main.url(forResource: name, withExtension: "wav")
                ?? Bundle.main.url(forResource: name, withExtension: "mp3")
            guard let url else { continue }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[name] = player
            } catch {
                // Sound file failed to load — will fall back to system sound
            }
        }
    }

    func play(_ name: String) {
        guard !isMuted else { return }

        // Prefer custom audio file if bundled
        if let player = players[name] {
            player.currentTime = 0
            player.play()
            return
        }

        // Fall back to system sound
        if let systemID = systemSoundFallbacks[name] {
            AudioServicesPlaySystemSound(systemID)
        }
    }
}
