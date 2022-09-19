//
//  UIImageView.swift
//  PodcastPlayerDemo
//
//  Created by ebpearls on 19/09/2022.
//

import UIKit
import AVFoundation
import Kingfisher

/// Extension to set image from video url and cache
extension UIImageView {
    func setImageFrom(videoURL: URL, completion: ((UIImage?) -> Void)? = nil) {
        let asset = AVURLAsset(url: videoURL)
        let key = videoURL.absoluteString
        DispatchQueue.global(qos: .userInteractive).async {
            if ImageCache.default.isCached(forKey: key) {
                DispatchQueue.main.async {
                    self.kf.setImage(with: videoURL, completionHandler:  { [weak self] _ in
                        completion?(self?.image)
                    })
                }
            } else {
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                
                let requestedTime: CMTime = asset.duration.seconds > 1 ? .zero : .positiveInfinity
                
                imageGenerator.requestedTimeToleranceBefore = requestedTime
                imageGenerator.requestedTimeToleranceAfter = requestedTime
                imageGenerator.appliesPreferredTrackTransform = true
                
                let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 100)
                
                imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { [weak self] (_, generatedImage, _, _, _) in
                    guard let self = self, let generatedImage = generatedImage else { return }
                    let image = UIImage(cgImage: generatedImage)
                    DispatchQueue.main.async {
                        self.image = image
                        completion?(image)
                    }
                    ImageCache.default.store(image, forKey: key)
                }
            }
        }
    }
}
