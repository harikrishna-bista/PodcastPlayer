//
//  PlayerViewControllerDataSource.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit

/// Datasource to provide the list of items for playing
public protocol PlayerViewControllerDataSource: AnyObject {
    
    /// Method to get the number of items in the list
    /// - Returns: Integer to denote the count of items
    func numberOfPlayerItems(in controller: PlayerViewController) -> Int
    
    /// Method to get the specific item at index
    /// - Returns: PlayerItem to be played at certain index
    func playerViewController(_ controller: PlayerViewController, itemAtIndex index: Int) -> PlayerItem?
}
