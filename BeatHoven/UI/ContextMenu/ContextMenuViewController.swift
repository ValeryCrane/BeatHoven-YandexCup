import Foundation
import UIKit

protocol ContextMenuViewControllerDelegate: AnyObject {
    func shouldCloseContextMenu()
}

extension ContextMenuViewController {
    private enum Constants {
        static let contextMenuVerticalPadding: CGFloat = 16
        static let contextMenuCornerRadius: CGFloat = 8
    }
}

/// Вьюконтроллер на котором показывается котекстное меню.
final class ContextMenuViewController: UIViewController {
    weak var delegate: ContextMenuViewControllerDelegate?
    
    private let contextMenuView: ContextMenuSuitable
    private let contextMenuFrame: CGRect
    
    private let shadowView = UIView()
    
    init(withContexMenuView contextMenuView: ContextMenuSuitable, forTargetView targetView: UIView) {
        self.contextMenuView = contextMenuView
        self.contextMenuFrame = Self.calculateContextMenuFrame(withContexMenuView: contextMenuView, forTargetView: targetView)
        
        super.init(nibName: nil, bundle: nil)
        
        contextMenuView.assignObserver(self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureShadowView()
        configureBackgroundGestureRecognizer()
        shadowView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.shadowView.alpha = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowView.frame = contextMenuFrame
        contextMenuView.frame = shadowView.bounds
    }
    
    private static func calculateContextMenuFrame(
        withContexMenuView contextMenuView: ContextMenuSuitable,
        forTargetView targetView: UIView
    ) -> CGRect {
        let targetViewFrame = targetView.superview?.convert(targetView.frame, to: nil) ?? .zero
        let contextMenuSize = contextMenuView.prefferedContextMenuSize()
        let screenSize = targetView.window?.windowScene?.screen.bounds.size ?? .zero
        
        let targetViewCenter = CGPoint(
            x: targetViewFrame.origin.x + targetViewFrame.width / 2,
            y: targetViewFrame.origin.y + targetViewFrame.height / 2
        )
        
        let contextMenuX: CGFloat = {
            if targetViewCenter.x > screenSize.width / 2 {
                return targetViewFrame.origin.x + targetViewFrame.size.width - contextMenuSize.width
            } else {
                return targetViewFrame.origin.x
            }
        }()
        
        let contextMenuY: CGFloat = {
            if targetViewCenter.y > screenSize.height / 2 {
                return targetViewFrame.origin.y - contextMenuSize.height - Constants.contextMenuVerticalPadding
            } else {
                return targetViewFrame.origin.y + targetViewFrame.size.height + Constants.contextMenuVerticalPadding
            }
        }()
        
        return .init(
            origin: .init(x: contextMenuX, y: contextMenuY),
            size: contextMenuSize
        )
    }
    
    private func configureShadowView() {
        view.addSubview(shadowView)
        shadowView.addSubview(contextMenuView)
        shadowView.layer.cornerRadius = Constants.contextMenuCornerRadius
        contextMenuView.layer.cornerRadius = Constants.contextMenuCornerRadius
        shadowView.backgroundColor = .white
        shadowView.clipsToBounds = false
        contextMenuView.clipsToBounds = true
        shadowView.apply(shadow: .init(elevation: 2))
    }
    
    private func configureBackgroundGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(shouldCloseContextMenu)
        )
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension ContextMenuViewController: ContextMenuSuitableObserver {
    
    @objc
    func shouldCloseContextMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.shadowView.alpha = 0
        }, completion: { _ in
            self.delegate?.shouldCloseContextMenu()
        })
    }
}

extension ContextMenuViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: view)
        for subview in view.subviews {
            if subview.frame.contains(point) {
                return false
            }
        }
        return true
    }
}

