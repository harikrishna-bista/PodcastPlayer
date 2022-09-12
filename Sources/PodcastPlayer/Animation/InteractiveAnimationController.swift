//
//  InteractiveAnimationController.swift
//  Podcast
//
//  Created by ebpearls on 09/09/2022.
//

import UIKit


/// AnimationClass to show  view expansion to fullscreen and collapse from fullscreen to a specific frame
class InteractiveAnimationController: NSObject {
    
    /// duration to take for present and dismiss animation
    private let animationDuration: Double
    
    /// type of animation: present or dismiss
    private let animationType: AnimationType
    
    /// presenting or dismiss view current frame
    private let initialFrame: CGRect
    
    /// presenting or dismiss view final frame
    private let finalFrame: CGRect
    
    
    /// Enum type to denote whether view is presented or  dismissed
    enum AnimationType {
        case present
        case dismiss
    }
    
    
    /// Init
    /// - Parameters:
    ///   - animationDuration: Duration of animation
    ///   - animationType: Type of Animation
    ///   - initialFrame: Current frame of animating view
    ///   - finalFrame: Final frame to acquire for animating view
    init(animationDuration: Double, animationType: AnimationType, initialFrame: CGRect, finalFrame: CGRect) {
        self.animationDuration = animationDuration
        self.animationType = animationType
        self.initialFrame = initialFrame
        self.finalFrame = finalFrame
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension InteractiveAnimationController: UIViewControllerAnimatedTransitioning {
    
    /// UIViewControllerAnimatedTransitioning transitionDuration method
    /// - Parameter transitionContext: UIViewControllerContextTransitioning
    /// - Returns: TimeInterval
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(exactly: animationDuration) ?? .zero
    }
    
    
    /// UIViewControllerAnimatedTransitioning animate method
    /// - Parameter transitionContext: UIViewControllerContextTransitioning
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
                  transitionContext.completeTransition(false)
                  return
              }
        
        switch animationType {
        case .present:
            transitionContext.containerView.addSubview(toViewController.view)
            presentAnimation(using: transitionContext, viewToAnimate: toViewController.view)
        case .dismiss:
            transitionContext.containerView.addSubview(toViewController.view)
            transitionContext.containerView.addSubview(fromViewController.view)
            dismissAnimation(using: transitionContext, viewToAnimate: fromViewController.view)
        }
    }
    
    /// Present animation
    /// - Parameters:
    ///   - transitionContext: UIViewControllerContextTransitioning
    ///   - viewToAnimate: Animating view
    private func presentAnimation(using transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        let containerView = transitionContext.containerView
        viewToAnimate.clipsToBounds = true
        
        let xScaleFactor = initialFrame.width / finalFrame.width
        let yScaleFactor = initialFrame.height / finalFrame.height
         
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        let duration = transitionDuration(using: transitionContext)
        viewToAnimate.transform = scaleTransform
        viewToAnimate.center = CGPoint(
          x: initialFrame.midX,
          y: initialFrame.midY)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
            viewToAnimate.transform = .identity
            viewToAnimate.center = CGPoint(x: containerView.frame.midX, y: containerView.frame.midY)
        } completion: { _ in
            transitionContext.completeTransition(true)
        }


    }
    // Dismiss animation
    /// - Parameters:
    ///   - transitionContext: UIViewControllerContextTransitioning
    ///   - viewToAnimate: Animating view
    private func dismissAnimation(using transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        let xScaleFactor = finalFrame.width / initialFrame.width
        let yScaleFactor = finalFrame.height / initialFrame.height
         
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) { [unowned self] () in
            viewToAnimate.transform = scaleTransform
            viewToAnimate.center = CGPoint(x: self.finalFrame.midX, y: self.finalFrame.midY)
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }
}
