import Foundation

/// Модель одного аудио сэмпла.
struct AudioSample: Codable {
    let fileURL: URL
    let sampleName: String
    let instrument: AudioInstrument
    let beats: Int
    
    init(fileURL: URL, sampleName: String, instrument: AudioInstrument, beats: Int = 4) {
        self.fileURL = fileURL
        self.sampleName = sampleName
        self.instrument = instrument
        self.beats = beats
    }
}

