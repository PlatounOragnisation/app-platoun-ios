//
//  CustomPresentationController.swift
//  Platoun
//
//  Created by Flavian Mary on 31/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

fileprivate let CORNER_RADIUS: CGFloat = 16

class CustomPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var dimmingView: UIView?
    var presentationWrappingView: UIView?
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedViewController.modalPresentationStyle = .custom
    }
    
    //    func presentedView() -> UIView {
    //        return self.presentationWrappingView
    //    }
    
    override var presentedView: UIView?{
        get { self.presentationWrappingView }
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedViewControllerView = super.presentedView else { return }
        
        let presentationWrapperView = UIView(frame: self.frameOfPresentedViewInContainerView)
        presentationWrapperView.layer.shadowOpacity = 0.44
        presentationWrapperView.layer.shadowRadius = 13.0
        presentationWrapperView.layer.shadowOffset = CGSize(width: 0, height: -6.0)
        self.presentationWrappingView = presentationWrapperView;
        
        
        let presentationRoundedCornerViewFrame = presentationWrapperView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -CORNER_RADIUS, right: 0))
        let presentationRoundedCornerView = UIView(frame: presentationRoundedCornerViewFrame)
        presentationRoundedCornerView.autoresizingMask = .init(arrayLiteral: .flexibleWidth, .flexibleHeight)
        presentationRoundedCornerView.layer.cornerRadius = CORNER_RADIUS
        presentationRoundedCornerView.layer.masksToBounds = true
        

        let presentedViewControllerWrapperViewFrame = presentationRoundedCornerView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: CORNER_RADIUS, right: 0))
        let presentedViewControllerWrapperView = UIView(frame: presentedViewControllerWrapperViewFrame)
        presentedViewControllerWrapperView.autoresizingMask = .init(arrayLiteral: .flexibleWidth, .flexibleHeight)
        
        presentedViewControllerView.autoresizingMask = .init(arrayLiteral: .flexibleWidth, .flexibleHeight)
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds
        presentedViewControllerWrapperView.addSubview(presentedViewControllerView)
        
        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
        presentationWrapperView.addSubview(presentationRoundedCornerView)
        
        
        let dimmingView = UIView(frame: self.containerView!.bounds)
        dimmingView.backgroundColor = .black
        dimmingView.isOpaque = false
        dimmingView.autoresizingMask = .init(arrayLiteral: .flexibleWidth, .flexibleHeight)
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped)))
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dimmingViewSwipped))
        swipeDown.direction = .down
        dimmingView.addGestureRecognizer(swipeDown)
        self.dimmingView = dimmingView
        self.containerView?.addSubview(dimmingView)
        
        
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        self.dimmingView?.alpha = 0
        transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView?.alpha = 0.5
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView?.alpha = 0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        let presentedContainer = (self.presentedViewController as UIContentContainer)
        
        if container.preferredContentSize == presentedContainer.preferredContentSize {
            self.containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let presentedContainer = (self.presentedViewController as UIContentContainer)
        
        if container.preferredContentSize == presentedContainer.preferredContentSize {
            return container.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            let containerViewBounds = self.containerView!.bounds
            let presentedViewContentSize = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerViewBounds.size)
            
            var presentedViewControllerFrame = containerViewBounds
            presentedViewControllerFrame.size.height = presentedViewContentSize.height
            presentedViewControllerFrame.origin.y = containerViewBounds.maxY - presentedViewContentSize.height
            return presentedViewControllerFrame
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        self.dimmingView?.frame = self.containerView!.bounds
        self.presentationWrappingView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    @objc func dimmingViewTapped(sender: UITapGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func dimmingViewSwipped(sender: UISwipeGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated ?? false ? 0.35 : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let isPresenting = fromViewController == self.presentingViewController
        
//        let fromViewInitialFrame = transitionContext.initialFrame(for: fromViewController)
        var fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
        
        var toViewInitialFrame = transitionContext.initialFrame(for: toViewController)
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
        
        if toView != nil {
            containerView.addSubview(toView!)
        }
        
        if isPresenting {
            toViewInitialFrame.origin = CGPoint(x: containerView.bounds.minX, y: containerView.bounds.maxY)
            toViewInitialFrame.size = toViewFinalFrame.size
            toView?.frame = toViewInitialFrame
        } else {
            if fromView != nil {
                fromViewFinalFrame = fromView!.frame.offsetBy(dx: 0, dy: fromView!.frame.height)
            }
        }
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: transitionDuration,
            animations: {
                if isPresenting {
                    toView?.frame = toViewFinalFrame
                } else {
                    fromView?.frame = fromViewFinalFrame
                }
        }) { finished in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(
            self.presentedViewController == presented,
            "You didn't initialize \(self) with the correct presentedViewController.  Expected \(presented), got \(self.presentedViewController).")
        
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
