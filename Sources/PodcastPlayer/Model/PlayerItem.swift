//
//  PlayerItem.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import Foundation
import UIKit

/// PlayerItem to be played
public struct PlayerItem {
    
    /// URL to play the media
    public let itemURL: URL
    
    /// URL to show thumbnail
    public let thumbnail: ImageSource?
    
    /// title to be shown
    public let trackName: String?
    
    /// description to be shown
    public let artistName: String?
    
    /// init
    public init(itemURL: URL, thumbnailURL: ImageSource?, trackName: String?, artistName: String?) {
        self.itemURL = itemURL
        self.thumbnail = thumbnailURL
        self.trackName = trackName
        self.artistName = artistName
    }
    
    var title: String {
        return trackName ?? itemURL.deletingPathExtension().lastPathComponent
    }
    var description: String {
        return artistName ?? itemURL.deletingPathExtension().lastPathComponent
    }
}


/// Public enum for different image Source
public enum ImageSource {
    /// Image to be displayed from url
    case url(URL)
    
    ///Image to be displayed from image
    case image(UIImage)
}
