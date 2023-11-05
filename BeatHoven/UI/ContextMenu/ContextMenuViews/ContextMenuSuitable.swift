import Foundation
import UIKit

protocol ContextMenuSuitableObserver: UIViewController {
    func shouldCloseContextMenu()
}

/// Протокол для вью, которые можно показать как контекстное меню.
protocol ContextMenuSuitable: UIView {
    func prefferedContextMenuSize() -> CGSize
    func assignObserver(_ observer: ContextMenuSuitableObserver)
}
