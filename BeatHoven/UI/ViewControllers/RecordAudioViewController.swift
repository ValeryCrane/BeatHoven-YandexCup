import Foundation
import UIKit
import AVFoundation

extension RecordAudioViewController {
    private enum Constants {
        static let buttonSize: CGFloat = 64
    }
}

final class RecordAudioViewController: UIViewController {
    
    private let beatTrackerView = BeatTrackerView(withBars: 1)
    
    private let globalStackView = UIStackView()
    
    private let beatsLabel = UILabel()
    private let beatsStepper = UIStepper()
    
    private let buttonsStackView = UIStackView()
    private let recordButton = UIButton()
    private let muteButton = UIButton()
    
    private var isRecording = false
    private var recordSilenceDelay: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureNavigationItem()
        configureGlobalStackView()
        layoutGlobalStackView()
        configureBeatsLabelAndStepper()
        layoutBeatsLabelAndStepper()
        layoutBeatTrackerView()
        configureButtonStackView()
        layoutButtonStackView()
        configureRecordButton()
        layoutRecordButton()
    }
    
    private func configureNavigationItem() {
        title = "Record sample"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeButtonWasPressed(_:))
        )
    }
    
    private func configureGlobalStackView() {
        globalStackView.axis = .vertical
        globalStackView.distribution = .equalSpacing
        globalStackView.spacing = 32
    }
    
    private func layoutGlobalStackView() {
        view.addSubview(globalStackView)
        globalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            globalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            globalStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            globalStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
    }
    
    private func configureBeatsLabelAndStepper() {
        beatsLabel.text = "Beats"
        beatsLabel.font = .systemFont(ofSize: 32)
        beatsStepper.value = 4
        beatsStepper.minimumValue = 4
        beatsStepper.maximumValue = 16
        beatsStepper.stepValue = 4
        beatsStepper.addTarget(self, action: #selector(beatsStepperValueWasChanged(_:)), for: .valueChanged)
    }
    
    private func layoutBeatsLabelAndStepper() {
        let wrapperView = UIView()
        [beatsLabel, beatsStepper].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            wrapperView.addSubview(view)
        }
        NSLayoutConstraint.activate([
            wrapperView.heightAnchor.constraint(equalToConstant: 64),
            beatsLabel.leftAnchor.constraint(equalTo: wrapperView.leftAnchor),
            beatsLabel.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor),
            beatsStepper.rightAnchor.constraint(equalTo: wrapperView.rightAnchor),
            beatsStepper.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor)
        ])
        globalStackView.addArrangedSubview(wrapperView)
    }
    
    private func layoutBeatTrackerView() {
        globalStackView.addArrangedSubview(beatTrackerView)
    }
    
    private func configureButtonStackView() {
        buttonsStackView.alignment = .center
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 32
    }
    
    private func layoutButtonStackView() {
        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureRecordButton() {
        recordButton.setImage(UIImage(named: "record")?.withInset(.init(top: 64, left: 64, bottom: 64, right: 64)), for: .normal)
        recordButton.backgroundColor = .white
        recordButton.tintColor = .black
        recordButton.largeContentImageInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        recordButton.layer.cornerRadius = 16
        recordButton.apply(shadow: .init(elevation: 1))
        recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
    }
    
    private func layoutRecordButton() {
        NSLayoutConstraint.activate([
            recordButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            recordButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
        buttonsStackView.addArrangedSubview(recordButton)
    }
    
    @objc
    private func closeButtonWasPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc
    private func beatsStepperValueWasChanged(_ sender: UIStepper) {
        beatTrackerView.setBars(Int(sender.value / 4))
    }
    
    @objc
    private func recordButtonPressed() {
        if !isRecording {
            recordSilenceDelay = AVAudioTime.seconds(forHostTime: mach_absolute_time()).truncatingRemainder(
                dividingBy: beatsStepper.value.rounded()
            )
            AudioMicrophoneRecorder.shared.startMicRecording()
        } else {
            let fileURL = AudioMicrophoneRecorder.shared.stopMicRecording()
            showCreateSampleAlert(
                withSampleURL: fileURL, 
                beats: Int(beatsStepper.value),
                silenceDelay: recordSilenceDelay
            )
        }
        
        isRecording.toggle()
        recordButton.backgroundColor = isRecording ? .black : .white
        recordButton.tintColor = isRecording ? .white : .black
        navigationItem.leftBarButtonItem?.isEnabled = !isRecording
    }
    
    private func showCreateSampleAlert(withSampleURL sampleURL: URL, beats: Int, silenceDelay: TimeInterval) {
        let alertController = UIAlertController(
            title: "Creating sample", message: "Enter sample name", preferredStyle: .alert
        )
        
        alertController.addTextField()
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak alertController, weak self] _ in
            if let textField = alertController?.textFields?.first as? UITextField {
                let audioFile = try! AVAudioFile(forReading: sampleURL)
                let sample = audioFile.sample(
                    withName: textField.text ?? "NO NAME",
                    durationBeats: beats,
                    silenceDelay: silenceDelay
                )
                self?.saveSample(sample)
            }
        }
        
        alertController.addAction(createAction)
        present(alertController, animated: true)
    }
    
    private func saveSample(_ sample: AudioSample) {
        if
            let samplesData = UserDefaults.standard.object(forKey: "VocalSamples") as? Data,
            let decoded = try? JSONDecoder().decode([AudioSample].self, from: samplesData)
        {
            if let encoded = try? JSONEncoder().encode(decoded + [sample]) {
                UserDefaults.standard.set(encoded, forKey: "VocalSamples")
            }
        } else {
            if let encoded = try? JSONEncoder().encode([sample]) {
                UserDefaults.standard.set(encoded, forKey: "VocalSamples")
            }
        }
    }
}
