import Foundation
import UIKit
import AVFoundation

extension BeatTrackerView {
    private enum Constants {
        static let beatViewHeight: CGFloat = 8
        static let beatViewSideOffsets: CGFloat = 2
        static let beatViewTopBottomOffsets: CGFloat = 2
        static let beatViewCornerRadius: CGFloat = 4
    }
}

/// Показывает какой на очереди бит.
final class BeatTrackerView: UIView {
    private var beatViews = [[BeatProgressView]]()
    
    init(withBars bars: Int) {
        super.init(frame: .zero)
        
        setBars(bars)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let beatWidth = bounds.width / 4
        let beatHeight = Constants.beatViewHeight + 2 * Constants.beatViewTopBottomOffsets
        for i in 0 ..< beatViews.count {
            for j in 0 ..< 4 {
                beatViews[i][j].frame = CGRect(
                    x: CGFloat(j) * beatWidth + Constants.beatViewSideOffsets,
                    y: CGFloat(i) * beatHeight + Constants.beatViewTopBottomOffsets,
                    width: beatWidth - 2 * Constants.beatViewSideOffsets,
                    height: Constants.beatViewHeight
                )
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        .init(
            width: UIView.noIntrinsicMetric,
            height: (Constants.beatViewHeight + 2 * Constants.beatViewTopBottomOffsets) * CGFloat(beatViews.count)
        )
    }
    
    func setBars(_ bars: Int) {
        for beatBar in beatViews {
            for beatView in beatBar {
                beatView.removeFromSuperview()
            }
        }
        beatViews = []
        
        for i in 0 ..< bars {
            beatViews.append([])
            for k in 0 ..< 4 {
                let beatView = BeatProgressView(beat: i * 4 + k, inTotalBeats: bars * 4)
                beatView.layer.cornerRadius = Constants.beatViewCornerRadius
                beatView.clipsToBounds = true
                addSubview(beatView)
                beatViews[i].append(beatView)
            }
        }

        setNeedsLayout()
        layoutIfNeeded()
    }
}

fileprivate class BeatProgressView: UIView {
    private let totalBeats: Int
    private let beat: Int
    
    private let progressBar = UIView(frame: .zero)
    
    init(beat: Int, inTotalBeats totalBeats: Int) {
        self.beat = beat
        self.totalBeats = totalBeats
        
        super.init(frame: .zero)
        
        backgroundColor = .systemGray6
        progressBar.backgroundColor = .green
        addSubview(progressBar)
        
        updateFilling(scheduleNextUpdate: true)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFilling(scheduleNextUpdate: false)
    }
    
    private func updateFilling(scheduleNextUpdate: Bool) {
        let beats = AVAudioTime.seconds(
            forHostTime: mach_absolute_time()
        ).truncatingRemainder(dividingBy: TimeInterval(totalBeats))
        
        if beats < Double(beat) {
            set(isFilled: false)
            if scheduleNextUpdate {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(beat) - beats + 0.0001) { [weak self] in
                    self?.updateFilling(scheduleNextUpdate: true)
                }
            }
        } else if beats < Double(beat + 1) {
            progressBar.layer.removeAllAnimations()
            progressBar.frame = .init(origin: bounds.origin, size: .init(
                width: (beats - Double(beat)) * bounds.width,
                height: bounds.height
            ))
            
            let completion: ((Bool) -> ())? = scheduleNextUpdate ? { [weak self] _ in
                self?.updateFilling(scheduleNextUpdate: true)
            } : nil
            UIView.animate(withDuration: Double(beat + 1) - beats + 0.0001, delay: 0, options: .curveLinear, animations: {
                self.progressBar.frame = self.bounds
            }, completion: completion)
        } else {
            set(isFilled: true)
            
            if scheduleNextUpdate {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalBeats) - beats + 0.0001) { [weak self] in
                    self?.updateFilling(scheduleNextUpdate: true)
                }
            }
        }
    }
    
    private func set(isFilled: Bool) {
        progressBar.layer.removeAllAnimations()
        if isFilled {
            progressBar.frame = bounds
        } else {
            progressBar.frame = .init(origin: bounds.origin, size: .init(width: 0, height: bounds.height))
        }
    }
}
