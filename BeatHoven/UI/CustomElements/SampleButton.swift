import Foundation
import UIKit

protocol SampleButtonDelegate: AnyObject {
    func sampleButtonDidUpdateState(_ sampleButton: SampleButton, isActive: Bool, withSample sample: AudioSample)
    func sampleButtonDidTapCreateSample(_ sampleButton: SampleButton)
}

extension SampleButton {
    private enum Constants {
        static let prefferedButtonDiameter: CGFloat = 64
        static let iconSize: CGFloat = 40
    }
}

/// Кнопка выбора и проигрывания сэмпла.
final class SampleButton: UIView {
    weak var delegate: SampleButtonDelegate?
    
    private let viewModel: ViewModel
    private let iconView = UIImageView()
    
    var isActive = false {
        didSet {
            backgroundColor = isActive ? viewModel.activeBackgroundColor : viewModel.backgroundColor
        }
    }
    private var currentSample: AudioSample?
    
    init(with viewModel: ViewModel, delegate: SampleButtonDelegate?) {
        self.delegate = delegate
        self.viewModel = viewModel
        self.currentSample = AudioSampleFactory.allSamplesOf(intrument: viewModel.instrument).first
        
        super.init(frame: .init(origin: .zero, size: .init(
            width: Constants.prefferedButtonDiameter,
            height: Constants.prefferedButtonDiameter
        )))
        
        backgroundColor = viewModel.backgroundColor
        configureIconView()
        setupGestureRecognizers()
    }
    
    override var intrinsicContentSize: CGSize {
        .init(
            width: Constants.prefferedButtonDiameter,
            height: Constants.prefferedButtonDiameter
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.frame = .init(
            x: (Constants.prefferedButtonDiameter - Constants.iconSize) / 2,
            y: (Constants.prefferedButtonDiameter - Constants.iconSize) / 2,
            width: Constants.iconSize,
            height: Constants.iconSize
        )
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
    private func configureIconView() {
        addSubview(iconView)
        iconView.image = viewModel.instrument.icon
        iconView.contentMode = .scaleAspectFit
        self.apply(shadow: .init(elevation: 1))
    }
    
    private func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        longPressGestureRecognizer.delaysTouchesBegan = true
        
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc
    private func onLongPress(_ sender: UIGestureRecognizer) {
        guard sender.state == .began else { return }
        
        ContextMenu.shared.show(contextMenuView: ChooseSampleContextMenuView(
            withDelegate: self,
            samples: AudioSampleFactory.allSamplesOf(intrument: viewModel.instrument),
            showCreateSampleButton: viewModel.instrument == .vocal
        ), forTargetView: self)
    }
    
    @objc
    private func onTap(_ sender: UIGestureRecognizer) {
        if let currentSample = currentSample {
            isActive.toggle()
            delegate?.sampleButtonDidUpdateState(self, isActive: isActive, withSample: currentSample)
        }
    }
}

extension SampleButton {
    struct ViewModel {
        static func classic(instrument: AudioInstrument) -> Self {
            .init(
                instrument: instrument,
                // Потому что нестабильно работает.
                backgroundColor: instrument != .vocal ? .white : .yellow,
                activeBackgroundColor: .green
            )
        }
        
        let instrument: AudioInstrument
        let backgroundColor: UIColor
        let activeBackgroundColor: UIColor
    }
}

extension SampleButton: ChooseSampleContextMenuViewDelegate {
    func didTapCreateSample() {
        delegate?.sampleButtonDidTapCreateSample(self)
    }
    
    func didChooseSample(_ sample: AudioSample) {
        currentSample = sample
        delegate?.sampleButtonDidUpdateState(self, isActive: isActive, withSample: sample)
    }
}
