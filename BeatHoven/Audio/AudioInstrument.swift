import Foundation
import UIKit

/// Типы инструментов.
enum AudioInstrument: Codable {
    case guitar
    case drums
    case brass
    case vocal
    
    var icon: UIImage {
        switch self {
        case .guitar:
            .init(named: "guitar")!
        case .drums:
            .init(named: "drums")!
        case .brass:
            .init(named: "trumpet")!
        case .vocal:
            .init(named: "vocal")!
        }
    }
}
