import Foundation
import UIKit

/// Вью контроллер для работы с аудио слоями.
final class AudioLayerViewController: UIViewController {
    weak var mixingManager: AudioMixingManager?
    
    private var layer: AudioLayer
    
    private let layersButton = UIButton()
    private let recordButton = UIButton()
    private let effectsStackView = UIStackView()
    private let effects: [AudioEffectMultisliderControlPresentable]
    
    private lazy var guitarButton: SampleButton = .init(with: .classic(instrument: .guitar), delegate: self)
    private lazy var drumsButton: SampleButton = .init(with: .classic(instrument: .drums), delegate: self)
    private lazy var brassButton: SampleButton = .init(with: .classic(instrument: .brass), delegate: self)
    private lazy var vocalButton: SampleButton = .init(with: .classic(instrument: .vocal), delegate: self)
    
    private lazy var layersButtons: [SampleButton] = [guitarButton, drumsButton, brassButton, vocalButton]
    private lazy var layersStackView = UIStackView(arrangedSubviews: layersButtons)
    
    init(layer: AudioLayer) {
        self.layer = layer
        self.effects = layer.viewModel.effects.map { .init(effect: $0) }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureStackView()
        layoutStackView()
        configureLayersButton()
        layoutLayersButton()
        configureRecordButton()
        layoutRecordButton()
        configureEffectsStackView()
        layoutEffectsStackView()
        
        setup(withViewModel: layer.viewModel)
    }
    
    private func setup(withViewModel viewModel: AudioLayer.ViewModel) {
        if let instrument = viewModel.sample?.instrument, viewModel.isPlaying {
            switch instrument {
            case .guitar:
                guitarButton.isActive = true
            case .drums:
                drumsButton.isActive = true
            case .brass:
                brassButton.isActive = true
            case .vocal:
                vocalButton.isActive = true
            }
        }
    }
    
    private func configureStackView() {
        layersStackView.axis = .horizontal
        layersStackView.distribution = .equalSpacing
    }
    
    private func layoutStackView() {
        view.addSubview(layersStackView)
        layersStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layersStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            layersStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            layersStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32)
        ])
    }
    
    private func configureLayersButton() {
        layersButton.setTitle("Layers", for: .normal)
        layersButton.setTitleColor(.white, for: .normal)
        layersButton.backgroundColor = .blue
        layersButton.layer.cornerRadius = 8
        layersButton.addTarget(self, action: #selector(layersButtonWasTapped(_:)), for: .touchUpInside)
    }
    
    private func layoutLayersButton() {
        view.addSubview(layersButton)
        layersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            layersButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            layersButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func configureRecordButton() {
        recordButton.setImage(UIImage(named: "record")?.withInset(.init(top: 64, left: 64, bottom: 64, right: 64)), for: .normal)
        recordButton.backgroundColor = .white
        recordButton.tintColor = .black
        recordButton.largeContentImageInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        recordButton.layer.cornerRadius = 8
        recordButton.apply(shadow: .init(elevation: 1))
        recordButton.addTarget(self, action: #selector(recordButtonWasTapped(_:)), for: .touchUpInside)
    }
    
    private func layoutRecordButton() {
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            recordButton.bottomAnchor.constraint(equalTo: layersButton.bottomAnchor),
            recordButton.topAnchor.constraint(equalTo: layersButton.topAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 64),
            recordButton.leftAnchor.constraint(equalTo: layersButton.rightAnchor, constant: 32)
        ])
    }
    
    private func configureEffectsStackView() {
        effectsStackView.axis = .vertical
        for effect in effects {
            effect.delegate = self
            effectsStackView.addArrangedSubview(MultisliderControl(withDelegate: effect, dataSource: effect))
        }
    }
    
    private func layoutEffectsStackView() {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.addSubview(effectsStackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        effectsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            effectsStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            effectsStackView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor),
            effectsStackView.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor),
            effectsStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            effectsStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: layersStackView.bottomAnchor, constant: 32),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: layersButton.topAnchor, constant: -32)
        ])
    }
    
    @objc private func layersButtonWasTapped(_ sender: UIButton) {
        ContextMenu.shared.show(
            contextMenuView: ChooseLayerContextMenuView(withDelegate: self, dataSource: self),
            forTargetView: layersButton
        )
    }
    
    @objc private func recordButtonWasTapped(_ sender: UIButton) {
        if AudioOutputRecorder.shared.isRecording {
            if let fileURL = AudioOutputRecorder.shared.stopRecording() {
                var filesToShare = [Any]()
                filesToShare.append(fileURL)
                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                present(activityViewController, animated: true, completion: nil)
            }
        } else {
            AudioOutputRecorder.shared.startRecording()
        }
        
        recordButton.backgroundColor = AudioOutputRecorder.shared.isRecording ? .black : .white
        recordButton.tintColor = AudioOutputRecorder.shared.isRecording ? .white : .red
    }
}

extension AudioLayerViewController: SampleButtonDelegate {
    func sampleButtonDidTapCreateSample(_ sampleButton: SampleButton) {
        let viewController = UINavigationController(rootViewController: RecordAudioViewController())
        viewController.isModalInPresentation = true
        present(viewController, animated: true)
    }
    
    func sampleButtonDidUpdateState(_ sampleButton: SampleButton, isActive: Bool, withSample sample: AudioSample) {
        if isActive {
            layersButtons.forEach { $0.isActive = ($0 == sampleButton) }
            try! layer.playSample(sample)
        } else {
            layer.stopPlaying()
        }
    }
}

extension AudioLayerViewController: ChooseLayerContextMenuViewDelegate, ChooseLayerContextMenuViewDataSource {
    func chooseLayerContextMenuView(didChooseLayerAtIndex layerIndex: Int) {
        if let mixingManager = mixingManager {
            mixingManager.audioMixingManagerShouldOpenEditor(
                forLayer: mixingManager.audioMixingManager(layerForIndex: layerIndex)
            )
        }
    }
    
    func chooseLayerContextMenuViewNumberOfLayers() -> Int {
        mixingManager?.audioMixingManagerNumberOfLayers() ?? 0
    }
    
    // TODO: Избавиться от force unwrap-а.
    func chooseLayerContextMenuView(layerViewModelForIndex layerIndex: Int) -> AudioLayer.ViewModel {
        mixingManager!.audioMixingManager(layerForIndex: layerIndex).viewModel
    }
    
    func chooseLayerContextMenuView(shouldCreateLayerWithName layerName: String) {
        mixingManager?.audioMixingManagerCreateLayer(withName: layerName)
    }
}

extension AudioLayerViewController: AudioEffectMultisliderControlPresentableDelegate {
    func audioEffectMultisliderControlPresentableEffectDidChange(_ effect: AudioEffect) {
        layer.updateEffect(effect)
    }
}
