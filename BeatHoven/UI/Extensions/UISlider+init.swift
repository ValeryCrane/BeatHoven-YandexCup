import Foundation
import UIKit

extension UISlider {
    convenience init(value: Float, minimumValue: Float, maximumValue: Float) {
        self.init()
        
        self.value = value
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
    }
}
