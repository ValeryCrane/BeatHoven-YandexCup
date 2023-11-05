import Foundation
import UIKit
import AVFoundation

/// Используется для снятия звука с микрофона.
final class AudioMicrophoneRecorder {
    static let shared = AudioMicrophoneRecorder()
    
    private var isMicRecording = false
    private var micRecordingURL: URL?
    private var micRecordingFile: AVAudioFile?
    
    func startMicRecording() {
        guard !isMicRecording else { return }
        
        micRecordingURL = createFileURL()
        do {
            micRecordingFile = try AVAudioFile(forWriting: micRecordingURL!, settings: AudioMixer.shared.getMicFormat().settings)
        } catch {
            print("AudioMicrophoneRecorder: Error creating audio file!")
        }
        
        
        AudioMixer.shared.addMicRecorder(handler: { [weak self] buffer, time in
            do {
                try self?.micRecordingFile?.write(from: buffer)
            } catch {
                print("AudioMicrophoneRecorder: Error writing buffer in file!")
            }
        })
    }
    
    func stopMicRecording() -> URL {
        defer {
            micRecordingFile = nil
            micRecordingURL = nil
        }
        AudioMixer.shared.removeMicRecorder()
        return micRecordingURL!
    }
    
    private func createFileURL() -> URL {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directoryURL.appendingPathComponent("audio\(UUID().uuidString).caf")
    }
    
    private init() { }
}
