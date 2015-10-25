//
//  ZoomTransition.swift
//  Transitions
//
//  Created by Tristan Himmelman on 2014-09-30.
//  Copyright (c) 2014 him. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol ZoomTransitionProtocol {
    func viewForTransition() -> UIView
}

public class ZoomTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    private var navigationController: UINavigationController
    private var fromView: UIView?
    private var toView: UIView?
    private var fromFrame: CGRect?
    private var toFrame: CGRect?
    private var transitionView: UIView?
    private var transitionContext: UIViewControllerContextTransitioning?
    private var fromViewController: UIViewController?
    private var toViewController: UIViewController?
    private var isPresenting: Bool = true
    private var shouldCompleteTransition: Bool = false
    private let completionThreshold: CGFloat = 0.7
    private var interactive: Bool = false
    
    var allowsInteractiveGesture = true
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - UIViewControllerAnimatedTransition Protocol
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if interactive {
            return 0.7
        }
        
        return 0.5
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey);
        toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey);
        
        if let viewController = toViewController as? ZoomTransitionProtocol {
            toView = viewController.viewForTransition()
        }
        if let viewController = fromViewController as? ZoomTransitionProtocol {
            fromView = viewController.viewForTransition()
        }
        
        // make sure toViewController is layed out
        toViewController?.view.frame = transitionContext.finalFrameForViewController(toViewController!)
        toViewController?.updateViewConstraints()

        assert(fromView != nil && toView != nil, "fromView and toView need to be set")
        
        let container = self.transitionContext!.containerView();
        
        // add toViewController to Transition Container
        if let view = toViewController?.view {
            if (isPresenting){
                container?.addSubview(view)
            } else {
                container?.insertSubview(view, belowSubview: fromViewController!.view)
            }
        }
        toViewController?.view.layoutIfNeeded()
        
        // Calculate animation frames within container view
        fromFrame = container?.convertRect(fromView!.bounds, fromView: fromView)
        toFrame = container?.convertRect(toView!.bounds, fromView: toView)
        
        // Create a copy of the fromView and add it to the Transition Container
        if let imageView = fromView as? UIImageView {
            transitionView = UIImageView(image: imageView.image)
        } else {
            transitionView = fromView?.snapshotViewAfterScreenUpdates(false);
        }
        
        if let view = transitionView {
            view.clipsToBounds = true
            view.frame = fromFrame!
            view.contentMode = fromView!.contentMode
            container?.addSubview(view)
        }
        
        if (isPresenting){
            animateZoomInTransition()
        } else {
            animateZoomOutTransition()
        }
    }
    
    // MARK: - Zoom animations
    
    func animateZoomInTransition(){
        if allowsInteractiveGesture {
            // add pinch gesture to new viewcontroller
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchGesture:"))
            pinchGesture.delegate = self
            toViewController?.view.addGestureRecognizer(pinchGesture)
            
            // add rotation gesture to new viewcontroller
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: Selector("handleRotationGesture:"))
            rotationGesture.delegate = self
            toViewController?.view.addGestureRecognizer(rotationGesture)
            
            // add pan gesture to new viewcontroller
            let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
            panGesture.delegate = self
            toViewController?.view.addGestureRecognizer(panGesture)
        }
        
        toViewController?.view.alpha = 0
        toView?.hidden = true
        fromView?.alpha = 0;
        
        let duration = transitionDuration(transitionContext!)
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in

            self.toViewController?.view.alpha = 1
            if (self.interactive == false){
                self.transitionView?.frame = self.toFrame!
            }
    
        }) { (Bool finished) -> Void in
            self.transitionView?.removeFromSuperview()
            self.fromViewController?.view.alpha = 1
            self.toView?.hidden = false
            self.fromView?.alpha = 1
            
            if (self.transitionContext!.transitionWasCancelled()){
                self.toViewController?.view.removeFromSuperview()
                self.isPresenting = true
                self.transitionContext!.completeTransition(false)
            } else {
                self.isPresenting = false
                self.transitionContext!.completeTransition(true)
            }
        }
    }
    
    func animateZoomOutTransition(){
        transitionView?.contentMode = toView!.contentMode
        
        toViewController?.view.alpha = 1

        toView?.hidden = true
        fromView?.alpha = 0;
        let duration = transitionDuration(transitionContext!)
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.fromViewController?.view.alpha = 0
            if (self.interactive == false){
                self.transitionView?.frame = self.toFrame!
            }
        }) { (Bool finished) -> Void in
            if self.interactive == false {
                self.zoomOutTransitionComplete()
            }
        }
    }
    
    func zoomOutTransitionComplete(){
        if (self.transitionView?.superview == nil){
            return
        }
        self.fromViewController?.view.alpha = 1
        self.toView?.hidden = false
        self.fromView?.alpha = 1
        self.transitionView?.removeFromSuperview()
        
        if (self.transitionContext!.transitionWasCancelled()){
            self.toViewController?.view.removeFromSuperview()
            self.isPresenting = false
            self.transitionContext!.completeTransition(false)
        } else {
            self.isPresenting = true
            self.transitionContext!.completeTransition(true)
        }
    }
    
    // MARK: - Gesture Recognizer Handlers
    
    func handlePinchGesture(gesture: UIPinchGestureRecognizer){
        switch (gesture.state) {
        case .Began:
            interactive = true;
            
            // begin transition
            self.navigationController.popViewControllerAnimated(true)
            break;
        case .Changed:

            self.transitionView?.transform = CGAffineTransformScale(self.transitionView!.transform, gesture.scale, gesture.scale)
            gesture.scale = 1
            
            // calculate current scale of transitionView
            let scale = self.transitionView!.frame.size.width / self.fromFrame!.size.width
            
            // Check if we should complete or restore transition when gesture is ended
            self.shouldCompleteTransition = (scale < completionThreshold);

            //println("scale\(1-scale)")
            updateInteractiveTransition(1-scale)
            
            break;
        case .Ended, .Cancelled:
            
            var animationFrame = toFrame
            let cancelAnimation = (self.shouldCompleteTransition == false && gesture.velocity >= 0) || gesture.state == UIGestureRecognizerState.Cancelled
            
            if (cancelAnimation){
                animationFrame = fromFrame
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
            
            // calculate current scale of transitionView
            let finalScale = animationFrame!.width / self.fromFrame!.size.width
            let currentScale = (transitionView!.frame.size.width / self.fromFrame!.size.width)
            let delta = finalScale - currentScale
            var normalizedVelocity = gesture.velocity / delta

            // add upper and lower bound on normalized velocity
            normalizedVelocity = normalizedVelocity > 20 ? 20 : normalizedVelocity
            normalizedVelocity = normalizedVelocity < -20 ? -20 : normalizedVelocity
            
            //println("---\nvelocity \(gesture.velocity)")
            //println("normal \(delta)")
            //println("velocity normal \(normalizedVelocity)")

            // no need to normalize the velocity for low velocities
            if gesture.velocity < 3 && gesture.velocity > -3 {
                normalizedVelocity = gesture.velocity
            }
            
            let duration = transitionDuration(transitionContext!)
            
            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: normalizedVelocity, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                // set a new transform to reset the rotation to 0 but maintain the current scale
                self.transitionView?.transform = CGAffineTransformMakeScale(currentScale, currentScale)
                
                if let frame = animationFrame {
                    self.transitionView?.frame = frame
                }
                self.transitionView?.contentMode = self.toView!.contentMode
                
            }, completion: { (Bool finished) -> Void in
                self.zoomOutTransitionComplete()
                self.interactive = false
            })

            break;
        default:
            break;
        }
    }
    
    func handleRotationGesture(gesture: UIRotationGestureRecognizer){
        if interactive {
            if gesture.state == UIGestureRecognizerState.Changed {
                transitionView!.transform = CGAffineTransformRotate(transitionView!.transform, gesture.rotation)
                gesture.rotation = 0
            }
        }
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer){
        let view = gesture.view!
        
        if interactive {
            if gesture.state == UIGestureRecognizerState.Changed {
                let translation = gesture.translationInView(view)
                transitionView?.center = CGPoint(x:transitionView!.center.x + translation.x, y:transitionView!.center.y + translation.y)
                gesture.setTranslation(CGPointZero, inView: view)
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (fromVC.conformsToProtocol(ZoomTransitionProtocol) && toVC.conformsToProtocol(ZoomTransitionProtocol)){
            return self
        }
        
        return nil;
    }

    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if (self.interactive){
            return self
        }
        
        return nil
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}