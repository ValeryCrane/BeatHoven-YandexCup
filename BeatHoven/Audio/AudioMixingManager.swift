import Foundation
import UIKit

/// Реализация работы над слоями
protocol AudioMixingManager: AnyObject {
    func audioMixingManagerNumberOfLayers() -> Int
    func audioMixingManager(layerForIndex layerIndex: Int) -> AudioLayer
    func audioMixingManagerShouldOpenEditor(forLayer layer: AudioLayer)
    func audioMixingManagerCreateLayer(withName name: String)
}
