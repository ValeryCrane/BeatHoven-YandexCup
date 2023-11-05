import Foundation
import AVFoundation

/// Класс - обертка над AVAudioEngine.
final class AudioMixer {
    static let shared = AudioMixer()
    private let engine = AVAudioEngine()
    
    func update(node: AVAudioNode, withFormat format: AVAudioFormat, effectNodes: [AVAudioNode] = []) {
        detach(node: node, effectNodes: effectNodes)
        attach(node: node, withFormat: format, effectNodes: effectNodes)
    }
    
    private func attach(node: AVAudioNode, withFormat format: AVAudioFormat, effectNodes: [AVAudioNode]) {
        ([node] + effectNodes).forEach { engine.attach($0) }
        if effectNodes.count > 0 {
            engine.connect(node, to: effectNodes[0], format: format)
            for i in 0 ..< effectNodes.count - 1 {
                engine.connect(effectNodes[i], to: effectNodes[i + 1], format: format)
            }
            engine.connect(effectNodes[effectNodes.count - 1], to: engine.mainMixerNode, format: format)
        } else {
            engine.connect(node, to: engine.mainMixerNode, format: format)
        }
        startIfNeeded()
    }
    
    private func detach(node: AVAudioNode, effectNodes: [AVAudioNode]) {
        ([node] + effectNodes).forEach { engine.detach($0) }
    }
    
    private func startIfNeeded() {
        do {
            try engine.start()
        } catch {
            print("Error starting the engine: \(error.localizedDescription)")
        }
    }
    
    private init() { }
}

// MARK: Microphone tap.

extension AudioMixer {
    func getMicFormat() -> AVAudioFormat {
        engine.inputNode.outputFormat(forBus: 0)
    }
    
    func addMicRecorder(handler: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void) {
        engine.inputNode.installTap(
            onBus: 0, bufferSize: 4096, format: engine.inputNode.outputFormat(forBus: 0), block: handler
        )
        startIfNeeded()
    }
    
    func removeMicRecorder() {
        engine.inputNode.removeTap(onBus: 0)
    }
}

// MARK: MainMixer tap.

extension AudioMixer {
    func getAudioFormat() -> AVAudioFormat {
        engine.mainMixerNode.outputFormat(forBus: 0)
    }
    
    func addAudioRecorder(handler: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void) {
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.mainMixerNode.installTap(
            onBus: 0, bufferSize: 4096, format: engine.mainMixerNode.outputFormat(forBus: 0), block: handler
        )
        startIfNeeded()
    }
    
    func removeAudioRecorder() {
        engine.mainMixerNode.removeTap(onBus: 0)
    }
}
