//
//  PlayerViewError.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import Foundation

/// Player view error or reason
public enum PlayerViewError: Error {
    /// reason to denote the user has skipped the play of current item
    case userSkipped
    
    /// error with reason such as: no internet, invalid playback url etc
    case error(String)
}


