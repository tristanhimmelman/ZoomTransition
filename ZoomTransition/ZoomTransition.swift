//
//  ZoomTransition.swift
//  Transitions
//
//  Created by Tristan Himmelman on 2014-09-30.
//  Updated to Swift 3 by Omar Albeik on 2016-12-26
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
	
	public init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	// MARK: - UIViewControllerAnimatedTransition Protocol
	
	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		if interactive {
			return 0.7
		}
		
		return 0.5
	}
	
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from);
		toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to);
		
		if let viewController = toViewController as? ZoomTransitionProtocol {
			toView = viewController.viewForTransition()
		}
		if let viewController = fromViewController as? ZoomTransitionProtocol {
			fromView = viewController.viewForTransition()
		}
		
		// make sure toViewController is layed out
		toViewController?.view.frame = transitionContext.finalFrame(for: toViewController!)
		toViewController?.updateViewConstraints()
		
		assert(fromView != nil && toView != nil, "fromView and toView need to be set")
		
		let container = self.transitionContext!.containerView
		
		// add toViewController to Transition Container
		if let view = toViewController?.view {
			if (isPresenting){
				container.addSubview(view)
			} else {
				container.insertSubview(view, belowSubview: fromViewController!.view)
			}
		}
		toViewController?.view.layoutIfNeeded()
		
		// Calculate animation frames within container view
		fromFrame = container.convert(fromView!.bounds, from: fromView)
		toFrame = container.convert(toView!.bounds, from: toView)
		
		// Create a copy of the fromView and add it to the Transition Container
		if let imageView = fromView as? UIImageView {
			transitionView = UIImageView(image: imageView.image)
		} else {
			transitionView = fromView?.snapshotView(afterScreenUpdates: false);
		}
		
		if let view = transitionView {
			view.clipsToBounds = true
			view.frame = fromFrame!
			view.contentMode = fromView!.contentMode
			container.addSubview(view)
		}
		
		if (isPresenting){
			animateZoomInTransition()
		} else {
			animateZoomOutTransition()
		}
	}
	
	// MARK: - Zoom animations
	
	func animateZoomInTransition() {
		if allowsInteractiveGesture {
			// add pinch gesture to new viewcontroller
			let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
			pinchGesture.delegate = self
			toViewController?.view.addGestureRecognizer(pinchGesture)
			
			// add rotation gesture to new viewcontroller
			let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
			rotationGesture.delegate = self
			toViewController?.view.addGestureRecognizer(rotationGesture)
			
			// add pan gesture to new viewcontroller
			let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
			panGesture.delegate = self
			toViewController?.view.addGestureRecognizer(panGesture)
		}
		
		toViewController?.view.alpha = 0
		toView?.isHidden = true
		fromView?.alpha = 0;
		
		let duration = transitionDuration(using: transitionContext!)
		UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
			
			self.toViewController?.view.alpha = 1
			if (self.interactive == false){
				self.transitionView?.frame = self.toFrame!
			}
			
		}) { (finished) -> Void in
			self.transitionView?.removeFromSuperview()
			self.fromViewController?.view.alpha = 1
			self.toView?.isHidden = false
			self.fromView?.alpha = 1
			
			if (self.transitionContext!.transitionWasCancelled){
				self.toViewController?.view.removeFromSuperview()
				self.isPresenting = true
				self.transitionContext!.completeTransition(false)
			} else {
				self.isPresenting = false
				self.transitionContext!.completeTransition(true)
			}
		}
	}
	
	func animateZoomOutTransition() {
		transitionView?.contentMode = toView!.contentMode
		
		toViewController?.view.alpha = 1
		
		toView?.isHidden = true
		fromView?.alpha = 0;
		let duration = transitionDuration(using: transitionContext!)
		
		UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
			self.fromViewController?.view.alpha = 0
			if (self.interactive == false){
				self.transitionView?.frame = self.toFrame!
			}
		}) { (finished) -> Void in
			if self.interactive == false {
				self.zoomOutTransitionComplete()
			}
		}
	}
	
	func zoomOutTransitionComplete() {
		if (self.transitionView?.superview == nil){
			return
		}
		self.fromViewController?.view.alpha = 1
		self.toView?.isHidden = false
		self.fromView?.alpha = 1
		self.transitionView?.removeFromSuperview()
		
		if (self.transitionContext!.transitionWasCancelled){
			self.toViewController?.view.removeFromSuperview()
			self.isPresenting = false
			self.transitionContext!.completeTransition(false)
		} else {
			self.isPresenting = true
			self.transitionContext!.completeTransition(true)
		}
	}
	
	// MARK: - Gesture Recognizer Handlers
	
	func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
		
		switch (gesture.state) {
		case .began:
			interactive = true;
			
			// begin transition
			self.navigationController.popViewController(animated: true)
			break;
		case .changed:
			
			self.transitionView?.transform = self.transitionView!.transform.scaledBy(x: gesture.scale, y: gesture.scale)
			gesture.scale = 1
			
			// calculate current scale of transitionView
			let scale = self.transitionView!.frame.size.width / self.fromFrame!.size.width
			
			// Check if we should complete or restore transition when gesture is ended
			self.shouldCompleteTransition = (scale < completionThreshold);
			
			//println("scale\(1-scale)")
			update(1-scale)
			
			break;
		case .ended, .cancelled:
			
			var animationFrame = toFrame
			let cancelAnimation = (self.shouldCompleteTransition == false && gesture.velocity >= 0) || gesture.state == UIGestureRecognizerState.cancelled
			
			if (cancelAnimation){
				animationFrame = fromFrame
				cancel()
			} else {
				finish()
			}
			
			// calculate current scale of transitionView
			let finalScale = animationFrame!.width / self.fromFrame!.size.width
			let currentScale = (transitionView!.frame.size.width / self.fromFrame!.size.width)
			let delta = finalScale - currentScale
			var normalizedVelocity = gesture.velocity / delta
			
			// add upper and lower bound on normalized velocity
			normalizedVelocity = normalizedVelocity > 20 ? 20 : normalizedVelocity
			normalizedVelocity = normalizedVelocity < -20 ? -20 : normalizedVelocity
			
			//print("---\nvelocity \(gesture.velocity)")
			//print("normal \(delta)")
			//print("velocity normal \(normalizedVelocity)")
			
			// no need to normalize the velocity for low velocities
			if gesture.velocity < 3 && gesture.velocity > -3 {
				normalizedVelocity = gesture.velocity
			}
			
			let duration = transitionDuration(using: transitionContext!)
			
			UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: normalizedVelocity, options: UIViewAnimationOptions(), animations: { () -> Void in
				
				// set a new transform to reset the rotation to 0 but maintain the current scale
				self.transitionView?.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
				
				if let frame = animationFrame {
					self.transitionView?.frame = frame
				}
				self.transitionView?.contentMode = self.toView!.contentMode
				
			}, completion: { (finished) -> Void in
				self.zoomOutTransitionComplete()
				self.interactive = false
			})
			
			break;
		default:
			break;
		}
	}
	
	func handleRotationGesture(_ gesture: UIRotationGestureRecognizer){
		if interactive {
			if gesture.state == UIGestureRecognizerState.changed {
				transitionView!.transform = transitionView!.transform.rotated(by: gesture.rotation)
				gesture.rotation = 0
			}
		}
	}
	
	func handlePanGesture(_ gesture: UIPanGestureRecognizer){
		let view = gesture.view!
		
		if interactive {
			if gesture.state == UIGestureRecognizerState.changed {
				let translation = gesture.translation(in: view)
				transitionView?.center = CGPoint(x:transitionView!.center.x + translation.x, y:transitionView!.center.y + translation.y)
				gesture.setTranslation(CGPoint.zero, in: view)
			}
		}
	}
	
	// MARK: - UINavigationControllerDelegate
	
	
	public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		guard fromVC.conforms(to: ZoomTransitionProtocol.self) && toVC.conforms(to: ZoomTransitionProtocol.self) else {
			return nil
		}
		
		return self
	}
	
	public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return interactive ? self : nil
	}
	
	// MARK: - UIGestureRecognizerDelegate
	
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

}
