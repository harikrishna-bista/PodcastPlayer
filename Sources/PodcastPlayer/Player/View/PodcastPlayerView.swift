//
//  PodcastPlayerView.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit


/// PodcastPlayerView that cofirms to playerView
public class PodcastPlayerView: UIView, PlayerView {

    /// Setting for podcast player
    public var setting: PlayerSetting { PodcastPlayerSetting() }
    
    ///  Container to show thumbnail or video frame
    public lazy var displayContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    /// Show podcast title
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    /// Show podcast description
    public var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textAlignment = .center
        return label
    }()
    
    /// button to expand video
    public var fullScreenButton: UIButton? = {
        let button = UIButton()
        button.setImage(UIImage(named: "expand", in: Bundle.module, with: nil), for: .normal)
        return button
    }()
    
    /// show current time in the podcast playing
    public var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0:0"
        return label
    }()
    
    /// show total length of the podcast
    public var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "0:0"

        return label
    }()

    /// slider to interact or show the current time of playback
    public var sliderControl: UISlider = {
        let slider = UISlider()
        return slider
    }()

    /// skip backward in the podcast playing
    public var skipBackwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        return button
    }()
    
    /// skip forward in the podcast playing
    public var skipForwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        return button
    }()

    /// play and pause button
    public var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        return button
    }()
    
    
    /// play previous button
    public var previousButton: UIButton  = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.end"), for: .normal)
        return button
    }()
    
    /// play next button
    public var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.end"), for: .normal)
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let displayStackView = UIStackView(arrangedSubviews: [displayContainerView, titleLabel, descriptionLabel])
        displayStackView.axis = .vertical
        displayStackView.spacing = 10
        
        let vStackView = UIStackView(arrangedSubviews: [displayStackView, getControlView()])
        vStackView.axis = .vertical
        vStackView.spacing = 40
        
        addSubview(vStackView)
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            vStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            vStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        if let fullScreenButton = fullScreenButton {
            displayContainerView.addSubview(fullScreenButton)
            fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
            fullScreenButton.trailingAnchor.constraint(equalTo: displayContainerView.trailingAnchor, constant: -5).isActive = true
            fullScreenButton.bottomAnchor.constraint(equalTo: displayContainerView.bottomAnchor, constant: -5).isActive = true
        }
    }
    
    private func getControlView() -> UIView {
        let timeLabelStackView = UIStackView(arrangedSubviews: [currentTimeLabel, UIView(), durationLabel])
        timeLabelStackView.axis = .horizontal
        
        let controlsStackView = UIStackView(arrangedSubviews: [skipBackwardButton, previousButton, playPauseButton, nextButton, skipForwardButton])
        controlsStackView.axis = .horizontal
        controlsStackView.alignment = .center
        controlsStackView.spacing = 20
        
        let controlsStackContainer = UIView()
        controlsStackContainer.addSubview(controlsStackView)
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.centerXAnchor.constraint(equalTo: controlsStackContainer.centerXAnchor).isActive = true
        controlsStackView.centerYAnchor.constraint(equalTo: controlsStackContainer.centerYAnchor).isActive = true
        controlsStackView.topAnchor.constraint(equalTo: controlsStackContainer.topAnchor).isActive = true
        controlsStackView.bottomAnchor.constraint(equalTo: controlsStackContainer.bottomAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [timeLabelStackView, sliderControl, controlsStackContainer])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setCustomSpacing(40, after: sliderControl)
        addSubview(stackView)
        
        return stackView
    }
}
