import AVFoundation
import SwiftUI

/// Lightweight audio player for bundled pronunciation files.
/// Handles loading and playing MP3 audio from the app bundle.
@MainActor
final class AudioPlayerService {
    static let shared = AudioPlayerService()

    private var player: AVAudioPlayer?
    private(set) var isPlaying = false

    private init() {}

    /// Play a bundled audio file by its relative path (e.g., "audio/lesson_001/kumain.mp3").
    /// Returns true if playback started, false if the file wasn't found.
    @discardableResult
    func play(relativePath: String) -> Bool {
        stop()

        // Try to find the audio file in the bundle
        let pathWithoutExtension = (relativePath as NSString).deletingPathExtension
        let ext = (relativePath as NSString).pathExtension

        guard let url = Bundle.main.url(forResource: pathWithoutExtension, withExtension: ext) else {
            return false
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            isPlaying = true
            return true
        } catch {
            return false
        }
    }

    /// Check if a bundled audio file exists for the given relative path.
    func hasAudio(relativePath: String) -> Bool {
        let pathWithoutExtension = (relativePath as NSString).deletingPathExtension
        let ext = (relativePath as NSString).pathExtension
        return Bundle.main.url(forResource: pathWithoutExtension, withExtension: ext) != nil
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }
}
