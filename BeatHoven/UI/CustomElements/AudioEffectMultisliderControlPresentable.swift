import Foundation
import UIKit

protocol AudioEffectMultisliderControlPresentableDelegate: AnyObject {
    func audioEffectMultisliderControlPresentableEffectDidChange(_ effect: AudioEffect)
}

/// Прослойка для управления аудио эффектами при помощи слайдеров.
final class AudioEffectMultisliderControlPresentable {
    weak var delegate: AudioEffectMultisliderControlPresentableDelegate?
    
    private var effect: AudioEffect {
        didSet {
            delegate?.audioEffectMultisliderControlPresentableEffectDidChange(effect)
        }
    }
    
    init(effect: AudioEffect) {
        self.effect = effect
    }
}

extension AudioEffectMultisliderControlPresentable: MultisliderControlDelegate {
    func multisliderControl(didChangeSliderValue sliderValue: Float, atIndex index: Int) {
        switch effect {
        case .distortion:
            effect = .distortion(wetDryMix: sliderValue)
        case .delay(time: let time, feedback: let feedback, wetDryMix: let wetDryMix):
            switch index {
            case 0:
                effect = .delay(time: sliderValue, feedback: feedback, wetDryMix: wetDryMix)
            case 1:
                effect = .delay(time: time, feedback: sliderValue, wetDryMix: wetDryMix)
            case 2:
                effect = .delay(time: time, feedback: feedback, wetDryMix: sliderValue)
            default:
                break
            }
        case .reverb:
            effect = .reverb(wetDryMix: sliderValue)
        case .volume:
            effect = .volume(value: sliderValue)
        }
    }
}

extension AudioEffectMultisliderControlPresentable: MultisliderControlDataSource {
    func multisliderControlTitle() -> String {
        switch effect {
        case .distortion: "Distortion"
        case .delay: "Delay"
        case .reverb: "Reverb"
        case .volume: "Volume"
        }
    }
    
    func multisliderControlNumberOfSliders() -> Int {
        switch effect {
        case .distortion: 1
        case .delay: 3
        case .reverb: 1
        case .volume: 1
        }
    }
    
    func multisliderControl(sliderViewModelForIndex index: Int) -> MultisliderControl.SliderViewModel {
        switch effect {
        case .distortion(wetDryMix: let wetDryMix):
            return .wetDryMix(value: wetDryMix)
        case .delay(time: let time, feedback: let feedback, wetDryMix: let wetDryMix):
            switch index {
            case 0:
                return .delayTime(value: time)
            case 1:
                return .delayFeedback(value: feedback)
            case 2:
                return .wetDryMix(value: wetDryMix)
            default:
                fatalError("")
            }
        case .reverb(wetDryMix: let wetDryMix):
            return .wetDryMix(value: wetDryMix)
        case .volume(value: let value):
            return .volumeValue(value: value)
        }
    }
    
    
}

fileprivate extension MultisliderControl.SliderViewModel{
    static func wetDryMix(value: Float) -> Self {
        .init(title: "wet/dry mix", minimalValue: 0, maximalValue: 100, value: value)
    }
    static func delayTime(value: Float) -> Self {
        .init(title: "time", minimalValue: 0, maximalValue: 2, value: value)
    }
    static func delayFeedback(value: Float) -> Self {
        .init(title: "feedback", minimalValue: -100, maximalValue: 100, value: value)
    }
    static func volumeValue(value: Float) -> Self {
        .init(title: "value", minimalValue: 0, maximalValue: 1, value: value)
    }
}
