import Foundation
import UIKit

extension UIImage {
    func withInset(_ insets: UIEdgeInsets) -> UIImage? {
        let cgSize = CGSize(
            width: size.width + insets.left * scale + insets.right * scale,
            height: size.height + insets.top * scale + insets.bottom * scale
        )

        UIGraphicsBeginImageContextWithOptions(cgSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        let origin = CGPoint(x: insets.left * scale, y: insets.top * scale)
        self.draw(at: origin)

        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(renderingMode)
    }
}
