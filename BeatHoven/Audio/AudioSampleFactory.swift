import Foundation

/// Место, где содаются аудио сэмплы
final class AudioSampleFactory {
    static let guitarMuted: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "muted", withExtension: ".wav")!,
        sampleName: "Muted",
        instrument: .guitar
    )
    static let guitarLead: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "funk-lead", withExtension: ".wav")!,
        sampleName: "Lead",
        instrument: .guitar
    )
    static let guitarUnisonBend: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "unison-bend", withExtension: ".wav")!,
        sampleName: "Unison Bend",
        instrument: .guitar
    )
    
    static let drumsOldfunk: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "oldfunk", withExtension: ".wav")!,
        sampleName: "Oldfunk",
        instrument: .drums
    )
    static let drumsOutdoor: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "outdoor", withExtension: ".wav")!,
        sampleName: "Outdoor",
        instrument: .drums
    )
    static let drumsOyaebu: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "oyaebu", withExtension: ".wav")!,
        sampleName: "Oyaebu",
        instrument: .drums
    )
    
    static let fluteTrumpet1: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "trumpet-1", withExtension: ".wav")!,
        sampleName: "Trumpet1",
        instrument: .brass
    )
    static let fluteTrumpet2: AudioSample = .init(
        fileURL: Bundle.main.url(forResource: "trumpet-2", withExtension: ".wav")!,
        sampleName: "Trumpet2",
        instrument: .brass
    )
    
    private init() { }
}

extension AudioSampleFactory {
    static func allSamplesOf(intrument: AudioInstrument) -> [AudioSample] {
        switch intrument {
        case .guitar:
            return [Self.guitarMuted, Self.guitarLead, Self.guitarUnisonBend]
        case .drums:
            return [Self.drumsOldfunk, Self.drumsOyaebu, Self.drumsOutdoor]
        case .brass:
            return [Self.fluteTrumpet1, Self.fluteTrumpet2]
        case .vocal:
            if 
                let data = UserDefaults.standard.object(forKey: "VocalSamples") as? Data,
                let samples = try? JSONDecoder().decode([AudioSample].self, from: data) 
            {
                 return samples
            }
            return []
        }
    }
}
