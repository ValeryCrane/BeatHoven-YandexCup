import Foundation
import UIKit

/// Класс, показывающий контекстное меню.
final class ContextMenu {
    static let shared = ContextMenu()
    private init() { }
    
    var window: UIWindow?
    
    func show(contextMenuView: ContextMenuSuitable, forTargetView targetView: UIView) {
        guard let windowScene = targetView.window?.windowScene else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        let viewController = ContextMenuViewController(withContexMenuView: contextMenuView, forTargetView: targetView)
        viewController.delegate = self
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

extension ContextMenu: ContextMenuViewControllerDelegate {
    func shouldCloseContextMenu() {
        window?.resignKey()
        window = nil
    }
}
