import Foundation
import AVFoundation

/// Сэмплирует записанное аудио в файл с четкой длительностью.
extension AVAudioFile {
    func sample(withName name: String, durationBeats: Int, silenceDelay: TimeInterval) -> AudioSample {
        let emptyBufferSize = Int(processingFormat.sampleRate * silenceDelay)
        let emptyBuffer = AVAudioPCMBuffer(
            pcmFormat: processingFormat,
            frameCapacity: AVAudioFrameCount(Int(processingFormat.sampleRate * silenceDelay))
        )!
        emptyBuffer.frameLength = emptyBuffer.frameCapacity
        
        let resultBuffer = AVAudioPCMBuffer(
            pcmFormat: processingFormat,
            frameCapacity: AVAudioFrameCount(Int(processingFormat.sampleRate) * durationBeats - emptyBufferSize)
        )!
        try! read(into: resultBuffer)
        
        let newFileURL = createFileURL(withName: name)
        let newFile = try! AVAudioFile(forWriting: newFileURL, settings: processingFormat.settings)
        try! newFile.write(from: emptyBuffer)
        try! newFile.write(from: resultBuffer)
        
        return .init(
            fileURL: newFileURL,
            sampleName: name,
            instrument: .vocal
        )
    }
    
    private func createFileURL(withName name: String) -> URL {
        let directoryURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        return directoryURL.appendingPathComponent("\(name).caf")
    }
}
