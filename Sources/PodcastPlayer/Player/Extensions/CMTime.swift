//
//  CMTime.swift
//  PodcastPlayerDemo
//
//  Created by ebpearls on 19/09/2022.
//

import Foundation
import AVFoundation

/// Extension to convert CMTime to textual information
extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours: Int { return Int(seconds / 3600) }
    var minute: Int { return Int(seconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(seconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}
