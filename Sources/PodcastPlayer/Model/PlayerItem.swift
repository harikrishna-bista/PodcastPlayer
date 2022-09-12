//
//  PlayerItem.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import Foundation

/// PlayerItem to be played
public struct PlayerItem {
    
    /// URL to play the media
    public let itemURL: URL
    
    /// URL to show thumbnail
    public let thumbnailURL: URL?
    
    /// title to be shown
    public let albumName: String?
    
    /// description to be shown
    public let trackName: String?
    
    /// init
    public init(itemURL: URL, thumbnailURL: URL?, albumName: String?, trackName: String?) {
        self.itemURL = itemURL
        self.thumbnailURL = thumbnailURL
        self.albumName = albumName
        self.trackName = trackName
    }
}
