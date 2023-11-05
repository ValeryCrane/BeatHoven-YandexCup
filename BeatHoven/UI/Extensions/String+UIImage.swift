import Foundation
import UIKit

extension String {

    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil) -> UIImage? {
        let size = (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(
                in: CGRect(origin: .zero, size: size),
                withAttributes: attributes
            )
        }
    }
    
}
