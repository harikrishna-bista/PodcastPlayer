//
//  PlayerViewHandler.swift
//  Podcast
//
//  Created by ebpearls on 08/09/2022.
//

import UIKit
import AVFoundation

/// Internal Enum to show the different state of the player
enum PlayerStatus {
    /// player is loading current item
    case isLoading
    
    /// player is playing current item
    case isPlaying
    
    /// player is pause
    case isPaused
    
    /// player failed to play for a reason
    case failed(String)
}

/// Internal delegate to handle the player events
protocol PlayerViewHandlerDelegate: AnyObject {
    
    /// event to denote the skip forward button tap
    func didSkipForward()
    
    /// event to denote skip backward button tap
    func didSkipBackward()
    
    /// event to denote previous button tap
    func didTapPrevious()
    
    /// event to denote next button tap
    func didTapNext()
    
    /// event to denote the current item completed playing
    func didFinishPlaying()
    
    /// event to denote the fullscreen button tap
    func didTapFullScreen()
    
    /// method to provide the change of player status
    func didChangePlayerStatus(_ status: PlayerStatus)
}


/// Class to perform all the player related heavy task
class PlayerViewHandler: NSObject {
    
    /// PlayerView that is used to display the current item
    private let playerView: PlayerView
    
    /// Layer to display video frame
    private let playerLayer: AVPlayerLayer = AVPlayerLayer(player: nil)
    
    /// Player to play from the url provided
    private var player: AVPlayer = AVPlayer(playerItem: nil)
    
    /// In memory cache to keep preloaded previous, current and next playerItem for faster interaction
    private var cache: [URL: AVPlayerItem] = [:]
    
    /// imageview to display thumbnail in displayContainerView of player
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    /// Context for observing playerItem
    private var playerItemContext = 0
    
    /// Observers for player
    private var playerObservers: [Any?] = []
    
    /// PlayerViewHandlerDelegate
    public weak var delegate: PlayerViewHandlerDelegate?
    
    
    /// Init
    /// - Parameter playerView: View the confirms to PlayerView protocol
    init(playerView: PlayerView) {
        self.playerView = playerView
        super.init()
        self.observeEvents()
        self.setupControlsGesture()
        self.addThumbnailImageView()
        self.addPlayerLayer()
    }
    
    /// Method for observing status of AVPlayerItem
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .failed:
                guard let playerItem = object as? AVPlayerItem else { return }
                delegate?.didChangePlayerStatus(.failed(playerItem.error!.localizedDescription))
            default:
                break
            }
        }
    }
    
    /// Deinitialized
    deinit  {
        debugPrint("deinit \(String(describing: self))")
        playerObservers = []
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
    
    // MARK: - Public
    
    /// Update UI for display container view
    func configureDisplayView() {
        self.playerLayer.frame = self.playerView.displayContainerView.bounds
    }
    
    /// Method to replay currentItem
    func replay() {
        seekToRatio(ratio: 0)
        play()
    }
    
    /// Prepare player to expand to fullscreen
    /// - Returns: Current player to be provide for AVKIT AVPlayerViewController
    func preparePlayerToExpand() -> AVPlayer {
        self.playerLayer.player = nil
        return player
    }
    
    /// Resume the player to play in the displayContainerView
    func preparePlayerToCollapse() {
        let status = player.timeControlStatus
        playerLayer.player = self.player
        
        if status == .playing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] () in //In fullScreen AVPlayerViewController will own this player, when AVPlayerViewController is dismissed they do cleanup in player so after delay we play that player when assigned to this playerLayer
                self.player.playImmediately(atRate: 1.0)
            }
        }
    }
    
    /// Method to play new item
    /// - Parameters:
    ///   - item: Item to be played
    ///   - previousItem: Previous item to be preloaded
    ///   - nextItem: Next item to be preloaded
    func startPlayingItem(item: PlayerItem, previousItem: PlayerItem?, nextItem: PlayerItem?) {
        var cache: [URL: AVPlayerItem] = [:]
        let currentPlayerItem = getAVPlayerItem(item: item, loadSync: true)
        
        player.replaceCurrentItem(with: currentPlayerItem)
        cache[item.itemURL] = currentPlayerItem
        if let previousItem = previousItem {
            cache[previousItem.itemURL] = getAVPlayerItem(item: previousItem)
        }
        if let nextItem = nextItem {
            cache[nextItem.itemURL] = getAVPlayerItem(item: nextItem)
        }
        self.cache = cache
        seekToRatio(ratio: 0)
        play()
        configurePlayerView(item: item)
    }

    
    //MARK: - Private
    
    /// Play
    private func play() {
        guard player.currentItem != nil else { return }
        if playerView.sliderControl.value == 1.0 {
            seekToRatio(ratio: 0)
        }
        player.play()
    }
    /// Pause
    private func pause() {
        player.pause()
    }
    
    /// Method to provide the playerItem from preloaded cached or new initialized
    /// - Parameters:
    ///   - item: item to be used to initialize AVPlayerItem
    ///   - loadSync: boolean to indicate preload to handle synchronously or asynchronously
    /// - Returns: AVPlayerItem for playing
    private func getAVPlayerItem(item: PlayerItem, loadSync: Bool = false) -> AVPlayerItem {
        if let item = cache[item.itemURL] {
            return item
        }
        let asset = AVAsset(url: item.itemURL)
        let keys = ["playable",
                    "hasProtectedContent", "duration"]
        var playerItem: AVPlayerItem!
        
        if loadSync {
            playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: keys)
        } else {
            asset.loadValuesAsynchronously(forKeys: keys, completionHandler: nil)
            playerItem = AVPlayerItem(asset: asset)
        }
        playerItem.addObserver(self,
                                   forKeyPath: #keyPath(AVPlayerItem.status),
                                   options: [.old, .new],
                                   context: &playerItemContext)
        NotificationCenter.default.addObserver(self, selector: #selector(currentItemFinishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        return playerItem
    }
    
    /// Update UI of PlayerView
    /// - Parameter item: Current Item
    private func configurePlayerView(item: PlayerItem) {
        updatePlayerViewLabels(item: item)
        updatePlayerDisplayContainer(item: item)
    }
    
    /// Update Display container based on current item
    /// - Parameter item: Current item
    private func updatePlayerDisplayContainer(item: PlayerItem) {
        let isVideo = isPlayerItemVideo(item: item)
        playerView.fullScreenButton?.isHidden = !isVideo
        
        let placeholder = defaultPlaceholderImage(item: item)
        if let thumbnail = item.thumbnailURL {
            switch thumbnail {
            case .url(let uRL):
                URLSession.shared.dataTask(with: uRL) { [weak self] data, _, _ in
                    DispatchQueue.main.async {
                        if let data = data, let image = UIImage(data: data) {
                            self?.thumbnailImageView.image = image
                        } else {
                            self?.thumbnailImageView.image = placeholder
                        }
                    }
                }.resume()
            case .image(let uIImage):
                self.thumbnailImageView.image = uIImage
            }
        } else {
            self.thumbnailImageView.image = placeholder
        }
        
        if isVideo {
            playerLayer.isHidden = false
            thumbnailImageView.isHidden = true
        } else {
            thumbnailImageView.isHidden = false
            playerLayer.isHidden = true
        }
    }
    
    /// Method to add thumbnail imageview in displaycontainerview
    private func addThumbnailImageView() {
        playerView.displayContainerView.addSubview(thumbnailImageView)
        playerView.displayContainerView.clipsToBounds = true
        thumbnailImageView.centerXAnchor.constraint(equalTo: playerView.displayContainerView.centerXAnchor).isActive = true
        thumbnailImageView.centerYAnchor.constraint(equalTo: playerView.displayContainerView.centerYAnchor).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalTo: playerView.displayContainerView.widthAnchor).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: playerView.displayContainerView.heightAnchor).isActive = true
    }
    
    /// Method to add videoplayerLayer in displaycontainerView
    private func addPlayerLayer() {
        playerView.displayContainerView.layer.insertSublayer(playerLayer, at: 0)
        playerLayer.player = player
    }
    
    /// Method to check if item in video
    /// - Parameter item: PlayerItem
    /// - Returns: Boolean
    private func isPlayerItemVideo(item: PlayerItem) -> Bool {
        return item.itemURL.absoluteString.hasSuffix(".mp4")
    }
    
    
    /// Default thumbnail provider
    /// - Parameter item: PlayerItem
    /// - Returns: UIImage?
    private func defaultPlaceholderImage(item: PlayerItem) -> UIImage? {
        if isPlayerItemVideo(item: item) {
            return UIImage(named: "video", in: Bundle.module, with: nil)
        }
        return UIImage(named: "audio", in: Bundle.module, with: nil)
    }
    
    /// Update the player textual infos
    /// - Parameter item: Player item
    private func updatePlayerViewLabels(item: PlayerItem) {
        var title: String = ""
        var desc: String = ""
        
        if let album = item.albumName, let track = item.trackName {
            title = album
            desc = track
        } else {
            let lastPath = item.itemURL.deletingPathExtension().lastPathComponent
            title = lastPath
            desc = lastPath
        }
        playerView.titleLabel.text = title
        playerView.descriptionLabel.text = desc
    }
    
    /// Method to add observers
    private func observeEvents() {
        addStatusObserver()
        addPeriodicObserver()
    }
    
    /// Player status observer
    private func addStatusObserver() {
        let timeControlObserver = self.player.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] (player, _) in
            guard let self = self else { return }
            switch player.timeControlStatus {
            case .playing:
                self.delegate?.didChangePlayerStatus(.isPlaying)
            case .paused:
                self.delegate?.didChangePlayerStatus(.isPaused)
            case .waitingToPlayAtSpecifiedRate:
                self.delegate?.didChangePlayerStatus(.isLoading)
            default:
                break
            }
        }
        playerObservers.append(timeControlObserver)
    }
    
    /// Time observer
    private func addPeriodicObserver() {

        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
   
        let mainQueue = DispatchQueue.main
    
        let periodicObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let self = self, let duration = self.player.currentItem?.duration else { return }
            guard duration.seconds.isFinite && !duration.seconds.isNaN else { return }
            self.updatePlaybackProgress(currentTime: time, duration: duration)
        }
        playerObservers.append(periodicObserver)
    }
    
    /// Update playback status
    /// - Parameters:
    ///   - currentTime: CMTime
    ///   - duration: CMTime
    private func updatePlaybackProgress(currentTime: CMTime, duration: CMTime) {
        playerView.durationLabel.text = duration.positionalTime
        playerView.currentTimeLabel.text = currentTime.positionalTime
        
        if !playerView.sliderControl.isTracking {
            playerView.sliderControl.value = Float(currentTime.seconds / duration.seconds)
        }
    }
    
    /// Handle playback based on the slider interaction
    /// - Parameter ratio: Position of slider
    private func seekToRatio(ratio: Float) {
        guard let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(ratio) * totalSeconds
        let time = CMTimeMakeWithSeconds(value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// Jump through current playing item track position
    /// - Parameter time: TimeInterval
    private func skipTime(time: TimeInterval) {
        let current = player.currentTime()
        let currentSeconds = CMTimeGetSeconds(current)
        let value = currentSeconds + time
        let time = CMTimeMakeWithSeconds(value, preferredTimescale: CMTimeScale(USEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
   
}

// MARK: - Handle control gesture
extension PlayerViewHandler {
    
    /// Setup controls event for playerView
    private func setupControlsGesture() {
        playerView.sliderControl.isUserInteractionEnabled = true
        playerView.sliderControl.addTarget(self, action: #selector(handleSliderValueChanged(_:)), for: .valueChanged)
        playerView.sliderControl.minimumValue = 0
        playerView.sliderControl.maximumValue = 1
        playerView.sliderControl.value = 0
         
        playerView.skipBackwardButton.isUserInteractionEnabled = true
        playerView.skipBackwardButton.addTarget(self, action: #selector(handleSkipBackwardTap), for: .touchUpInside)
        
        playerView.skipForwardButton.isUserInteractionEnabled = true
        playerView.skipForwardButton.addTarget(self, action: #selector(handleSkipForwardTap), for: .touchUpInside)
        
        playerView.playPauseButton.isUserInteractionEnabled = true
        playerView.playPauseButton.addTarget(self, action: #selector(handlePlayPauseTap), for: .touchUpInside)
        
        playerView.previousButton.isUserInteractionEnabled = true
        playerView.previousButton.addTarget(self, action: #selector(handlePreviousTap), for: .touchUpInside)
        
        playerView.nextButton.isUserInteractionEnabled = true
        playerView.nextButton.addTarget(self, action: #selector(handleNextTap), for: .touchUpInside)
        
        playerView.fullScreenButton?.isUserInteractionEnabled = true
        playerView.fullScreenButton?.addTarget(self, action: #selector(handleFullScreenTap), for: .touchUpInside)
    }
    
    /// Handle playpause button tap
    @objc private func handlePlayPauseTap() {
        switch player.timeControlStatus {
        case .paused:
            play()
        case .playing:
            pause()
        default:
            break
        }
    }
    
    /// Handle previous button tap
    @objc private func handlePreviousTap() {
        delegate?.didTapPrevious()
    }
    /// Handle next button tap
    @objc private func handleNextTap() {
        delegate?.didTapNext()
    }
    /// Handle skipForward button tap
    @objc private func handleSkipForwardTap() {
        skipTime(time: playerView.setting.skipTimeInSeconds)
        delegate?.didSkipForward()
    }
    /// Handle skipBackward button tap
    @objc private func handleSkipBackwardTap() {
        skipTime(time: -playerView.setting.skipTimeInSeconds)
        delegate?.didSkipBackward()
    }
    /// Handle fullscreen button tap
    @objc private func handleFullScreenTap() {
        delegate?.didTapFullScreen()
    }
    /// Handle slider value changed through interaction
    @objc private func handleSliderValueChanged(_ sender: UISlider) {
        seekToRatio(ratio: sender.value)
    }
    /// Handle when current item finishes playing
    @objc private func currentItemFinishedPlaying() {
        delegate?.didFinishPlaying()
    }
   
}

/// Extension to convert CMTime to textual information
extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours: Int { return Int(seconds / 3600) }
    var minute: Int { return Int(seconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(seconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}

/*extension UIImageView {
    func loadImage(_ asset: AVAsset, completion: ((UIImage?) -> Void)? = nil) {
        guard let asset = asset as? AVURLAsset else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            
            let requestedTime: CMTime = asset.duration.seconds > 1 ? .zero : .positiveInfinity
            
            imageGenerator.requestedTimeToleranceBefore = requestedTime
            imageGenerator.requestedTimeToleranceAfter = requestedTime
            imageGenerator.appliesPreferredTrackTransform = true
            
            let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 100)
            
            imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { [weak self] (_, generatedImage, _, _, _) in
                guard let self = self, let generatedImage = generatedImage else { return }
                let image = UIImage(cgImage: generatedImage)
                DispatchQueue.main.async {
                    self.image = image
                    completion?(image)
                }
            }
        }
    }
}*/
