import Foundation
import UIKit

protocol MultisliderControlDelegate: AnyObject {
    func multisliderControl(didChangeSliderValue sliderValue: Float, atIndex index: Int)
}

protocol MultisliderControlDataSource: AnyObject {
    func multisliderControlTitle() -> String
    func multisliderControlNumberOfSliders() -> Int
    func multisliderControl(sliderViewModelForIndex index: Int) -> MultisliderControl.SliderViewModel
}

extension MultisliderControl {
    private enum Constants {
        static let titleTopOffset: CGFloat = 16
        static let sideOffsets: CGFloat = 16
        static let titleBottomOffset: CGFloat = 8
        static let sliderTitleTopOffset: CGFloat = 8
        static let sliderTopOffset: CGFloat = 8
        static let sliderBottomOffset: CGFloat = 8
        
        static let titleFontSize: CGFloat = 18
        static let sliderTitleFontSize: CGFloat = 12
        static let sliderValuesFontSize: CGFloat = 12
    }
}

/// Контрол с несколькими слайдерами. Используется для аэудио эффектов.
final class MultisliderControl: UIView {
    private weak var delegate: MultisliderControlDelegate?
    private weak var dataSource: MultisliderControlDataSource?
    
    private let titleLabel = UILabel()
    private let slidersStackView = UIStackView()
    private var sliders: [UISlider] = []
    
    init(withDelegate delegate: MultisliderControlDelegate, dataSource: MultisliderControlDataSource) {
        self.delegate = delegate
        self.dataSource = dataSource
        
        super.init(frame: .zero)
        
        configureTitleLabelAndStackView()
        layoutTitleLabel()
        layoutStackView()
        reloadData()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        guard let dataSource = dataSource else { return }
        
        titleLabel.text = dataSource.multisliderControlTitle()
        sliders = []
        for slider in slidersStackView.subviews {
            slidersStackView.removeArrangedSubview(slider)
            slider.removeFromSuperview()
        }
        let numberOfSliders = dataSource.multisliderControlNumberOfSliders()
        for i in 0 ..< numberOfSliders {
            let (sliderView, slider) = createSlider(
                withViewModel: dataSource.multisliderControl(sliderViewModelForIndex: i)
            )
            slidersStackView.addArrangedSubview(sliderView)
            slider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
            sliders.append(slider)
        }
    }
    
    private func configureTitleLabelAndStackView() {
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize)
        titleLabel.textAlignment = .center
        slidersStackView.axis = .vertical
    }
    
    private func layoutTitleLabel() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleTopOffset),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Constants.sideOffsets),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.sideOffsets)
        ])
    }
    
    private func layoutStackView() {
        addSubview(slidersStackView)
        slidersStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slidersStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.titleBottomOffset),
            slidersStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: Constants.sideOffsets),
            slidersStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.sideOffsets),
            slidersStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createSlider(withViewModel viewModel: SliderViewModel) -> (UIView, UISlider) {
        let sliderView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = viewModel.title
        titleLabel.font = .systemFont(ofSize: Constants.sliderTitleFontSize)
        titleLabel.textAlignment = .center
        
        let slider = UISlider(
            value: viewModel.value,
            minimumValue: viewModel.minimalValue,
            maximumValue: viewModel.maximalValue
        )
        slider.minimumValueImage = String(slider.minimumValue).image(withAttributes: [
            .font: UIFont.systemFont(ofSize: Constants.sliderValuesFontSize)
        ])
        slider.maximumValueImage = String(slider.maximumValue).image(withAttributes: [
            .font: UIFont.systemFont(ofSize: Constants.sliderValuesFontSize)
        ])
        
        [titleLabel, slider].forEach { view in
            sliderView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: sliderView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: sliderView.rightAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: Constants.sliderTitleTopOffset),
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.sliderTopOffset),
            slider.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: Constants.sliderBottomOffset)
        ])
        
        return (sliderView, slider)
    }
    
    @objc
    private func sliderDidChangeValue(_ sender: UISlider) {
        for i in 0 ..< sliders.count {
            if sender === sliders[i] {
                delegate?.multisliderControl(didChangeSliderValue: sender.value, atIndex: i)
            }
        }
    }
}

extension MultisliderControl {
    struct SliderViewModel {
        let title: String
        let minimalValue: Float
        let maximalValue: Float
        let value: Float
    }
}
