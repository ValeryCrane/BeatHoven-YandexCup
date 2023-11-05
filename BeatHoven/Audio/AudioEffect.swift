import Foundation

/// Модели аудио эффектов.
enum AudioEffect {
    case distortion(wetDryMix: Float)
    case delay(time: Float, feedback: Float, wetDryMix: Float)
    case reverb(wetDryMix: Float)
    case volume(value: Float)
}
