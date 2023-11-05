import Foundation
import UIKit


/// Пункт меню выбора сэмпла.
final class ChooseSampleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ChooseSampleTableViewCell"
    
    private let sampleTitle = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layout()
    }
    
    @available(*,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(withSample sample: AudioSample) {
        sampleTitle.text = sample.sampleName
    }
    
    private func layout() {
        contentView.addSubview(sampleTitle)
        sampleTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sampleTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            sampleTitle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            sampleTitle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            sampleTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
