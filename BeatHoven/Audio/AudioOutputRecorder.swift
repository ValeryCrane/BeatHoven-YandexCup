import Foundation
import UIKit
import AVFoundation

/// Используется для снятия звука с главного микшера.
final class AudioOutputRecorder {
    static let shared = AudioOutputRecorder()
    
    private(set) var isRecording = false
    private var recordingURL: URL?
    private var recordingFile: AVAudioFile?
    
    func startRecording() {
        guard !isRecording else { return }
        
        isRecording = true
        recordingURL = createFileURL()
        do {
            recordingFile = try AVAudioFile(forWriting: recordingURL!, settings: AudioMixer.shared.getAudioFormat().settings)
        } catch {
            print("AudioOutputRecorder: Error creating audio file!")
        }
        
        AudioMixer.shared.addAudioRecorder(handler: { [weak self] buffer, time in
            do {
                try self?.recordingFile?.write(from: buffer)
            } catch {
                print("AudioMicrophoneRecorder: Error writing buffer in file!")
            }
        })
    }
    
    func stopRecording() -> URL? {
        defer {
            recordingFile = nil
            recordingURL = nil
        }
        AudioMixer.shared.removeAudioRecorder()
        return recordingURL
    }
    
    private func createFileURL() -> URL {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directoryURL.appendingPathComponent("audio\(UUID().uuidString).caf")
    }
    
    private init() { }
}
