//
//  PlayerViewController.swift
//  Podcast
//
//  Created by ebpearls on 08/09/2022.
//

import UIKit
import AVKit
import MediaPlayer

/// Public class to play audio, podcast or video
public class PlayerViewController: UIViewController {
    
    /// datasource that provides the list
    public weak var dataSource: PlayerViewControllerDataSource? { didSet { configurePlayList() }}
    
    /// delegate to handle the events of player
    public weak var delegate: PlayerViewControllerDelegate?
    
    /// View to be shown by the controller as main view
    private let playerView: PlayerView
    
    /// Helper class to handle playerView interaction and events
    private let playerViewHandler: PlayerViewHandler
    
    /// numberof items to be played
    private var numberOfItems: Int = .zero
    
    /// current index in the list
    private var currentIndex: Int = -1
    
    /// current item of the list
    private var currentItem: PlayerItem?
    
    /// track the fullscreen to small screen
    private var isPlayerWasInFullScreenMode: Bool = false
    
    /// Relative rect of the playerView video frame for animation
    private lazy var playerViewDisplayContainerRelativeRect: CGRect = {
        let rect = getDisplayContainerViewRelativeFrame(frame: playerView.thumbnailImageView.frame, superView: playerView.thumbnailImageView.superview)
        let cal = view.convert(rect, to: view.window)
        return cal
    }()
    
    
    /// Init
    /// - Parameter playerView: Any view confirming to PlayerView
    public init(playerView: PlayerView? = nil) {
        self.playerView = playerView ?? PodcastPlayerView()
        self.playerViewHandler = PlayerViewHandler(playerView: self.playerView)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Make playerView as mainview
    public override func loadView() {
        super.loadView()
        view = playerView
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// ViewDidLoad
    public override func viewDidLoad() {
        super.viewDidLoad()
        playerViewHandler.delegate = self
        playerViewHandler.configureDisplayView()
        setupAudioSession()
        configureNavigation()
    }
    public override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        playerViewHandler.configureDisplayView()
    }
    /// ViewWillAppear
    /// - Parameter animated: Boolean
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isPlayerWasInFullScreenMode {
            playerViewHandler.preparePlayerToCollapse()
            isPlayerWasInFullScreenMode = false
        }
    }
    deinit  {
        debugPrint("deinit \(String(describing: self))")
    }
    
    /// ViewDidLayoutSubviews
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerViewHandler.configureDisplayView()
    }
    
    /// Reloads the list
    public func reloadPlaylist() {
        numberOfItems = .zero
        currentIndex = -1
        configurePlayList()
    }
    
    private func configureNavigation() {
        if presentingViewController != nil {
            let image = UIImage(systemName: "multiply")
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(handleDismiss))
        }
    }
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            assertionFailure("Audio playback issue \(error.localizedDescription)")
        }
    }
    @objc private func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    //MARK: - Setup Data source
    
    /// Configure playlist
    private func configurePlayList() {
        guard let itemsCount = dataSource?.numberOfPlayerItems(in: self), itemsCount > 0 else {
            numberOfItems = .zero
            return
        }
        numberOfItems = itemsCount
        changeTrack(to: 0)
    }
    
    @discardableResult
    /// Change play to specified index
    /// - Parameter index: Int
    /// - Returns: Boolean to indicated sucessful in changing track
    private func changeTrack(to index: Int) -> Bool {
        guard (0..<numberOfItems).contains(index) else {
            if currentIndex >= 0 {
                playerViewHandler.replay()
            }
            return false
        }
        guard let item = getItem(at: index) else { fatalError("No item to play at index \(index)") }
        
        if delegate?.playerViewController(self, canPlayItem: item, atIndex: index) == false {
            return false
        }
        var previous: PlayerItem?
        var next: PlayerItem?
        if index > 0 {
            previous = getItem(at: index - 1)
        }
        if index < numberOfItems - 1 {
            next = getItem(at: index + 1)
        }
        currentItem = item
        currentIndex = index
        playerViewHandler.startPlayingItem(item: item, previousItem: previous, nextItem: next)
        return true
    }
    
    /// Method to get item at Index
    /// - Parameter index: Int
    /// - Returns: PlayerItem?
    private func getItem(at index: Int) -> PlayerItem? {
        guard let item = dataSource?.playerViewController(self, itemAtIndex: index) else { return nil }
        return item
    }

    
    /// Method to recursively calculate the videoFrame relative to the viewController view for animation
    /// - Parameters:
    ///   - frame: CGRect to be converted
    ///   - superView: SuperView of the view
    /// - Returns: CGRect
    private func getDisplayContainerViewRelativeFrame(frame: CGRect, superView: UIView?) -> CGRect {
        if let superView = superView, let anotherSuperView = superView.superview {
            if anotherSuperView is PlayerView {
                return superView.convert(frame, to: anotherSuperView)
            } else {
                let frame = superView.convert(frame, to: anotherSuperView)
                return getDisplayContainerViewRelativeFrame(frame: frame, superView: anotherSuperView)
            }
        }
        fatalError("PlayerView doesn't have subview to display")
    }
    
}

// MARK: - PlayerViewHandlerDelegate
extension PlayerViewController: PlayerViewHandlerDelegate {
    
    /// Handle skip forward in the playerView
    func didSkipForward() {
        guard let currentItem = currentItem else { return }
        delegate?.playerViewController(self, didSkipForwardOnItem: currentItem, atIndex: currentIndex)
    }
    /// Handle skip backward in the playerView
    func didSkipBackward() {
        guard let currentItem = currentItem else { return }
        delegate?.playerViewController(self, didSkipBackwardOnItem: currentItem, atIndex: currentIndex)
    }
    /// Handle play previous in the playerView
    func didTapPrevious() {
        if changeTrack(to: currentIndex - 1) {
            delegate?.playerViewController(self, didSkipItemAtIndex: currentIndex + 1, withReason: .userSkipped)
        }
    }
    /// Handle play next in the playerView
    func didTapNext() {
        if changeTrack(to: currentIndex + 1) {
            delegate?.playerViewController(self, didSkipItemAtIndex: currentIndex - 1, withReason: .userSkipped)
        }
    }
    /// Handle finished current item playing the playerView
    func didFinishPlaying() {
        if playerView.setting.playNextAutomatically {
            guard currentIndex < numberOfItems - 1 else { return }
            changeTrack(to: currentIndex + 1)
        }
    }
    /// Handle expand video in the playerView
    func didTapFullScreen() {
        let player = playerViewHandler.preparePlayerToExpand()
        let fullScreenPlayerViewController = AVPlayerViewController()
        fullScreenPlayerViewController.allowsPictureInPicturePlayback = false
        fullScreenPlayerViewController.updatesNowPlayingInfoCenter = false
        fullScreenPlayerViewController.player = player
        fullScreenPlayerViewController.transitioningDelegate = self
        
        let navigationController = UINavigationController(rootViewController: fullScreenPlayerViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.transitioningDelegate = self
        present(navigationController, animated: true) {
            self.isPlayerWasInFullScreenMode = true
        }
    }
    /// Handle player status change in the playerView
    func didChangePlayerStatus(_ status: PlayerStatus) {
        switch status {
        case .isLoading:
            break
        case .isPlaying:
            playerView.playPauseButton.setImage(playerView.setting.pauseIcon, for: .normal)
            delegate?.playerViewController(self, didStartPlayingItem: currentItem!, atIndex: currentIndex)
        case .isPaused:
            playerView.playPauseButton.setImage(playerView.setting.playIcon, for: .normal)
            delegate?.playerViewController(self, didPauseItem: currentItem!, atIndex: currentIndex)
        case .failed(let reason):
            delegate?.playerViewController(self, didSkipItemAtIndex: currentIndex, withReason: .error(reason))
            changeTrack(to: currentIndex + 1)
        }
    }
}
// MARK: - UIViewControllerTransitioningDelegate
extension PlayerViewController: UIViewControllerTransitioningDelegate {
    /// Expand video to fullscreen
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return InteractiveAnimationController(animationDuration: 0.2, animationType: .present, initialFrame: playerViewDisplayContainerRelativeRect, finalFrame: view.frame)
    }
    /// Collapse video from fullscreen to small frame
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return InteractiveAnimationController(animationDuration: 0.1, animationType: .dismiss, initialFrame: view.frame, finalFrame: playerViewDisplayContainerRelativeRect)
    }
}
