//
//  PodcastPlayerSetting.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit


/// Podcast player setting the confirms to playerSetting
public class PodcastPlayerSetting: PlayerSetting {
    
    /// Pause icon to show when podcast is playing
    public var pauseIcon: UIImage? { UIImage(systemName: "pause") }
    
    /// Play icon to show when podcast is paused
    public var playIcon: UIImage? { UIImage(systemName: "play") }
    
    /// time to skip forward or backward when podcast is playing
    public var skipTimeInSeconds: Double { 10 }
    
    /// boolean to enable local caching of podcast
    public var enableCaching: Bool { false }

    /// boolean to indicate if next podcase should play automatically
    public var playNextAutomatically: Bool { true }

}
