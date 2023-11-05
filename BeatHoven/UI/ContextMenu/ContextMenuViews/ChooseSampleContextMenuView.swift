import Foundation
import UIKit

protocol ChooseSampleContextMenuViewDelegate: AnyObject {
    func didChooseSample(_ sample: AudioSample)
    func didTapCreateSample()
}

/// Контекстное меню выбора сэмпла.
final class ChooseSampleContextMenuView: UIView {
    private weak var delegate: ChooseSampleContextMenuViewDelegate?
    private weak var observer: ContextMenuSuitableObserver?
    
    private var samples: [AudioSample]
    private let tableView = UITableView()
    private let showCreateSampleButton: Bool
    
    init(withDelegate delegate: ChooseSampleContextMenuViewDelegate, samples: [AudioSample], showCreateSampleButton: Bool) {
        self.samples = samples
        self.delegate = delegate
        self.showCreateSampleButton = showCreateSampleButton
        
        super.init(frame: .zero)
        
        configureTableView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
    }
    
    private func configureTableView() {
        addSubview(tableView)
        tableView.register(ChooseSampleTableViewCell.self, forCellReuseIdentifier: ChooseSampleTableViewCell.reuseIdentifier)
        tableView.register(AddContextMenuTableViewCell.self, forCellReuseIdentifier: AddContextMenuTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ChooseSampleContextMenuView: ContextMenuSuitable {
    func prefferedContextMenuSize() -> CGSize {
        .init(width: 180, height: 240)
    }
    
    func assignObserver(_ observer: ContextMenuSuitableObserver) {
        self.observer = observer
    }
}

extension ChooseSampleContextMenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < samples.count else {
            delegate?.didTapCreateSample()
            observer?.shouldCloseContextMenu()
            return
        }
        delegate?.didChooseSample(samples[indexPath.row])
        observer?.shouldCloseContextMenu()
    }
}

extension ChooseSampleContextMenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        samples.count + (showCreateSampleButton ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < samples.count else {
            return tableView.dequeueReusableCell(
                withIdentifier: AddContextMenuTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? AddContextMenuTableViewCell ?? UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChooseSampleTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ChooseSampleTableViewCell
        cell?.setup(withSample: samples[indexPath.row])
        
        return cell ?? UITableViewCell()
    }
}

