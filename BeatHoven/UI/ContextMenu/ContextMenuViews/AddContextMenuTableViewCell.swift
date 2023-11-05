import Foundation
import UIKit

/// Пункт меню "+".
final class AddContextMenuTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AddContextMenuTableViewCell"
    
    private let layerTitle = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layerTitle.text = "+"
        layout()
    }
    
    @available(*,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(layerTitle)
        layerTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layerTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            layerTitle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            layerTitle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            layerTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
