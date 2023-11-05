import Foundation
import AVFoundation

extension AudioLayer {
    private enum Constants {
        static let defaultSampleRate: Int = 48000
    }
}

/// Слой проигрывания аудио.
final class AudioLayer {
    var viewModel: ViewModel {
        .init(
            name: name,
            isPlaying: node.isPlaying,
            sample: sample, 
            effects: [
                .distortion(wetDryMix: distortionUnit.wetDryMix),
                .delay(time: Float(delayUnit.delayTime), feedback: delayUnit.feedback, wetDryMix: delayUnit.wetDryMix),
                .reverb(wetDryMix: reverbUnit.wetDryMix),
                .volume(value: node.volume)
            ]
        )
    }
    
    private let name: String
    private let node = AVAudioPlayerNode()
    private let distortionUnit = AVAudioUnitDistortion()
    private let delayUnit = AVAudioUnitDelay()
    private let reverbUnit = AVAudioUnitReverb()
    private var sample: AudioSample?
    
    init(name: String) {
        self.name = name
        removeAllEffects()
    }
    
    func playSample(_ sample: AudioSample) throws {
        self.sample = sample
        let audioBuffer = try createPCMBufferFrom(sample: sample)
        AudioMixer.shared.update(node: node, withFormat: audioBuffer.format, effectNodes: [
            delayUnit, distortionUnit, reverbUnit
        ])
        node.scheduleBuffer(audioBuffer, at: calculateStartingTime(forBeats: sample.beats), options: .loops)
        node.play()
    }
    
    func stopPlaying() {
        node.stop()
    }
    
    func updateEffect(_ effect: AudioEffect) {
        switch effect {
        case .distortion(wetDryMix: let wetDryMix):
            distortionUnit.wetDryMix = wetDryMix
        case .delay(time: let time, feedback: let feedback, wetDryMix: let wetDryMix):
            delayUnit.delayTime = TimeInterval(time)
            delayUnit.feedback = feedback
            delayUnit.wetDryMix = wetDryMix
        case .reverb(wetDryMix: let wetDryMix):
            reverbUnit.wetDryMix = wetDryMix
        case .volume(value: let value):
            node.volume = value
        }
    }
    
    private func removeAllEffects() {
        distortionUnit.preGain = 0
        distortionUnit.wetDryMix = 0
        delayUnit.delayTime = 0
        delayUnit.feedback = 0
        delayUnit.wetDryMix = 0
        reverbUnit.wetDryMix = 0
        reverbUnit.loadFactoryPreset(.cathedral)
        node.volume = 1
    }
    
    private func createPCMBufferFrom(sample: AudioSample) throws -> AVAudioPCMBuffer {
        let audioFile = try AVAudioFile(forReading: sample.fileURL)
        let audioBuffer = AVAudioPCMBuffer(
            pcmFormat: audioFile.processingFormat,
            frameCapacity: AVAudioFrameCount(Constants.defaultSampleRate * sample.beats)
        )
        if let audioBuffer = audioBuffer {
            try audioFile.read(into: audioBuffer)
            return audioBuffer
        } else {
            throw InstrumentError.couldntReadFile
        }
    }
    
    private func calculateStartingTime(forBeats beats: Int) -> AVAudioTime {
        let machTime = mach_absolute_time()
        let timeToWait = machTime.quotientAndRemainder(
            dividingBy: AVAudioTime.hostTime(forSeconds: TimeInterval(beats))
        ).remainder
        return .init(hostTime: machTime - timeToWait)
    }
}

extension AudioLayer {
    struct ViewModel {
        let name: String
        let isPlaying: Bool
        let sample: AudioSample?
        let effects: [AudioEffect]
    }
}

enum InstrumentError: Error {
    case couldntReadFile
}

