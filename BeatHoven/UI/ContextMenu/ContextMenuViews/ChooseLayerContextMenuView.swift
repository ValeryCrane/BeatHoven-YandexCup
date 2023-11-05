import Foundation
import UIKit

protocol ChooseLayerContextMenuViewDelegate: AnyObject {
    func chooseLayerContextMenuView(didChooseLayerAtIndex layerIndex: Int)
    func chooseLayerContextMenuView(shouldCreateLayerWithName layerName: String)
}

protocol ChooseLayerContextMenuViewDataSource: AnyObject {
    func chooseLayerContextMenuViewNumberOfLayers() -> Int
    func chooseLayerContextMenuView(layerViewModelForIndex layerIndex: Int) -> AudioLayer.ViewModel
}

/// Контекстное меню выбора слоя.
final class ChooseLayerContextMenuView: UIView {
    private weak var delegate: ChooseLayerContextMenuViewDelegate?
    private weak var dataSource: ChooseLayerContextMenuViewDataSource?
    private weak var observer: ContextMenuSuitableObserver?
    
    private let tableView = UITableView()
    
    init(
        withDelegate delegate: ChooseLayerContextMenuViewDelegate,
        dataSource: ChooseLayerContextMenuViewDataSource
    ) {
        self.delegate = delegate
        self.dataSource = dataSource
        
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
        tableView.register(ChooseLayerTableViewCell.self, forCellReuseIdentifier: ChooseLayerTableViewCell.reuseIdentifier)
        tableView.register(AddContextMenuTableViewCell.self, forCellReuseIdentifier: AddContextMenuTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func showCreateLayerAlert() {
        let alertController = UIAlertController(
            title: "Creating layer", message: "Enter layer name", preferredStyle: .alert
        )
        alertController.addTextField()
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak alertController, weak self] _ in
            if let textField = alertController?.textFields?.first as? UITextField {
                self?.delegate?.chooseLayerContextMenuView(shouldCreateLayerWithName: textField.text ?? "")
                self?.observer?.shouldCloseContextMenu()
            }
        }
        alertController.addAction(createAction)
        observer?.present(alertController, animated: true)
    }
    
}

extension ChooseLayerContextMenuView: ContextMenuSuitable {
    func prefferedContextMenuSize() -> CGSize {
        .init(width: 180, height: 240)
    }
    
    func assignObserver(_ observer: ContextMenuSuitableObserver) {
        self.observer = observer
    }
}

extension ChooseLayerContextMenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < (dataSource?.chooseLayerContextMenuViewNumberOfLayers() ?? 0) else {
            showCreateLayerAlert()
            return
        }
        
        delegate?.chooseLayerContextMenuView(didChooseLayerAtIndex: indexPath.row)
        observer?.shouldCloseContextMenu()
    }
}

extension ChooseLayerContextMenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (dataSource?.chooseLayerContextMenuViewNumberOfLayers() ?? 0 ) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < (dataSource?.chooseLayerContextMenuViewNumberOfLayers() ?? 0) else {
            return tableView.dequeueReusableCell(
                withIdentifier: AddContextMenuTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? AddContextMenuTableViewCell ?? UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChooseLayerTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ChooseLayerTableViewCell
        if let viewModel = dataSource?.chooseLayerContextMenuView(layerViewModelForIndex: indexPath.row) {
            cell?.setup(withLayerViewModel: viewModel)
        }
        
        return cell ?? UITableViewCell()
    }
}
