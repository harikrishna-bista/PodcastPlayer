//
//  PlayerView.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit


/// Custom playerView to show when playing media
public protocol PlayerView: UIView {
    ///  Container view to show thumbnails, video frame
    var displayContainerView: UIView { get }
    
    /// title info about item playing
    var titleLabel: UILabel { get }
    
    /// description info about item playing
    var descriptionLabel: UILabel { get }
    
    /// label to show the current time of item playing
    var currentTimeLabel: UILabel { get }
    
    /// label to show the length of the item
    var durationLabel: UILabel { get }
    
    /// control to show the current time of the item also acts as free control to move to anywhere in the item
    var sliderControl: UISlider { get }
    
    /// button to jump backward to specified seconds in the item
    var skipBackwardButton: UIButton { get }
    
    /// button jump forward to specified seconds in the item
    var skipForwardButton: UIButton { get }
    
    /// button to play and pause the item
    var playPauseButton: UIButton { get }
    
    /// play the previous item in the list
    var previousButton: UIButton { get }
    
    /// play the next item in the list
    var nextButton: UIButton { get }
    
    /// button to expand the video to fullscreen
    var fullScreenButton: UIButton? { get }
    
    /// settings to apply to the player
    var setting: PlayerSetting { get }
}

