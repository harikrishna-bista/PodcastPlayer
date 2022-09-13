//
//  PodcastPlayerSetting.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit


/// Podcast player setting the confirms to playerSetting
class PodcastPlayerSetting: PlayerSetting {
    
    /// Pause icon to show when podcast is playing
    var pauseIcon: UIImage? { UIImage(systemName: "pause") }
    
    /// Play icon to show when podcast is paused
    var playIcon: UIImage? { UIImage(systemName: "play") }
    
    /// time to skip forward or backward when podcast is playing
    var skipTimeInSeconds: Double { 10 }
    
    /// boolean to enable local caching of podcast
    var enableCaching: Bool { false }

    /// boolean to indicate if next podcase should play automatically
    var playNextAutomatically: Bool { true }

}
