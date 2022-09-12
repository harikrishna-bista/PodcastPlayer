//
//  PlayerViewControllerDelegate.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit


/// Delegate to handle the different events and state of player
public protocol PlayerViewControllerDelegate: AnyObject {
    
    /// method to provide the event of item being skipped forward, this info can be useful in analytics
    func playerViewController(_ controller: PlayerViewController, didSkipForwardOnItem item: PlayerItem, atIndex index: Int)
    
    /// method to provide the event of item being skipped backward, this info can be useful in analytics
    func playerViewController(_ controller: PlayerViewController, didSkipBackwardOnItem item: PlayerItem, atIndex index: Int)
    
    /// method to denote the event of item being played
    func playerViewController(_ controller: PlayerViewController, didStartPlayingItem item: PlayerItem, atIndex index: Int)
    
    /// method to denote the event of item being paused
    func playerViewController(_ controller: PlayerViewController, didPauseItem item: PlayerItem, atIndex index: Int)
    
    /// method to ask whether a item can be played
    /// - Returns: Boolean
    func playerViewController(_ controller: PlayerViewController, canPlayItem item: PlayerItem, atIndex index: Int) -> Bool
    
    /// method to denote a event when entire item is skipped for a reason
    func playerViewController(_ controller: PlayerViewController, didSkipItemAtIndex index: Int, withReason reason: PlayerViewError)
}

public extension PlayerViewControllerDelegate {
    func playerViewController(_ controller: PlayerViewController, canPlayItem item: PlayerItem, atIndex index: Int) -> Bool { return true }
}
