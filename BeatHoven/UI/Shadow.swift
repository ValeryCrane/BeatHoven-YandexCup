import Foundation
import UIKit

struct Shadow {
    let color: CGColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
    
    init(elevation: UInt) {
        self.color = UIColor.black.cgColor
        self.offset = .zero
        self.radius = CGFloat(16 * elevation)
        self.opacity = 0.25
    }
}

extension UIView {
    func apply(shadow: Shadow) {
        layer.shadowColor = shadow.color
        layer.shadowOffset = shadow.offset
        layer.shadowRadius = shadow.radius
        layer.shadowOpacity = shadow.opacity
        layer.masksToBounds = false
    }
}
