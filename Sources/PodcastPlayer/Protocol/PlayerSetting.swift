//
//  PlayerSetting.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit

/// Player setting to be implemented
public protocol PlayerSetting: AnyObject {
    
    /// pause icon to show in the player when playing
    var pauseIcon: UIImage? { get }
    
    /// play icon to show in the player when paused
    var playIcon: UIImage? { get }
    
    /// seconds to go backward for forward when specific control is used to skip through item
    var skipTimeInSeconds: Double { get }
    
    /// boolean to indicate caching of the item, this is currently not implemented in this version
    var enableCaching: Bool { get }
    
    /// boolean to indicate if the next item should be played automatically when current item finishes playing
    var playNextAutomatically: Bool { get }
}
