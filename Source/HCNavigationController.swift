//
//  HCNavigationController.swift
//  HCNavigationController
//
//  Created by chen he on 2019/4/2.
//  Copyright © 2019 chen he. All rights reserved.
//


import Cocoa

public protocol HCNavigationControllerDelegate : NSObjectProtocol {
    
}


public enum NavigationOperation {
    case Push
    case Pop
}

/*
 HCNavigationController is a UINavigationController alike component brought to Cocoa
 */
public class HCNavigationController: NSViewController {
    // Convenience method pushes the root view controller without animation.
    // you must specify frame, since there may no window to attach.
    public init(withFrame frame: CGRect, rootViewController: NSViewController?) {
        super.init(nibName: nil, bundle: nil)
        setup(with: frame, rootViewController: rootViewController)
    }
    
    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup(with: .zero, rootViewController: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(with: .zero, rootViewController: nil)
    }
    
    private func setup(with frame: CGRect, rootViewController: NSViewController?) {
        self.view = NSView(frame: frame)
        self.view.autoresizingMask = [.minXMargin, .minYMargin, .width, .maxXMargin, .maxYMargin, .height]
        
        var viewController: NSViewController
        if rootViewController == nil {
            viewController = NSViewController()
            viewController.view = NSView(frame: frame)
        } else {
            viewController = rootViewController!
        }
        
        viewControllers = [viewController]
        
        viewController.view.autoresizingMask = [.minXMargin, .minYMargin, .width, .maxXMargin, .maxYMargin, .height]
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
    }
    
    // Uses a horizontal slide transition. Has no effect if the view controller is already in the stack.
    open func pushViewController(_ viewController: NSViewController, animated: Bool) {
        
        let topViewController = self.topViewController
        
        viewControllers.append(viewController)
        
        transition(from: topViewController, to: self.topViewController, animated: animated)
    }
    
    // Returns the popped controller.
    open func popViewController(animated: Bool) -> NSViewController? {
        // rootViewController is not allowed to pop
        if viewControllers.count == 1 {
            return nil
        }
        
        // last view controller
        let poppedViewController = self.topViewController
        viewControllers = viewControllers.dropLast()
        
        transition(from: poppedViewController, to: self.topViewController, animated: animated, operation: .Pop)
        
        return poppedViewController
    }
    
    // Pops view controllers until the one specified is on top. Returns the popped controllers.
    open func popToViewController(_ viewController: NSViewController, animated: Bool) -> [NSViewController]? {
        // last one.
        if viewController == topViewController {
            return nil
        }
        
        // destination view controller must be in the stack
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        // from viewcontroller.next to last
        var poppedViewControllers = [NSViewController]()
        for i in index+1..<viewControllers.count {
            poppedViewControllers.append(viewControllers[i])
        }
        viewControllers = viewControllers.dropLast(viewControllers.count - index - 1)

        transition(from: topViewController, to: viewController, animated: animated)
        
        return poppedViewControllers
    }
    
    // Pops until there's only a single view controller left on the stack. Returns the popped controllers.
    open func popToRootViewController(animated: Bool) -> [NSViewController]? {
        return popToViewController(rootViewController, animated: animated)
    }

    // The top view controller on the stack.
    open var topViewController: NSViewController {
        get {
            return viewControllers.last!
        }
    }
    
    // The current view controller stack.
    open private(set) var viewControllers = [NSViewController]()
    
    
    open var rootViewController: NSViewController {
        return viewControllers.first!
    }

    
    /*
     Actually, we just transition between two subviews.
     */
    private func transition(from fromViewController: NSViewController, to toViewController: NSViewController, animated: Bool, operation: NavigationOperation = .Push) {
        
        toViewController.view.autoresizingMask = self.view.autoresizingMask
        
        var fromViewControllerToFrame = self.view.bounds
        var toViewControllerFromFrame = self.view.bounds

        
        if !animated {
            fromViewController.view.removeFromSuperview()
            toViewController.view.frame = self.view.bounds
            view.addSubview(toViewController.view)
            return
        }
        
        // animate frame change
        switch operation {
        case .Push:
            // toViewController from right to left.
            fromViewControllerToFrame.origin.x = -self.view.frame.size.width
            toViewControllerFromFrame.origin.x = self.view.frame.size.width
            
        case .Pop:
            /// Pop fromViewController, offset width to the right.
            fromViewControllerToFrame.origin.x = self.view.frame.size.width
            toViewControllerFromFrame.origin.x = -self.view.frame.size.width
        }
        
        
        toViewController.view.frame = toViewControllerFromFrame
        fromViewController.view.removeFromSuperview()
        
        let fromControllerSnapshot = NSImageView(frame: self.view.bounds)
        let toControllerSnapshot = NSImageView(frame: toViewControllerFromFrame)
        
        fromControllerSnapshot.image = fromViewController.view.snapshot()
        toControllerSnapshot.image = toViewController.view.snapshot()
        
        self.view.addSubview(fromControllerSnapshot)
        self.view.addSubview(toControllerSnapshot)
        
        NSAnimationContext.current.completionHandler = {
            toViewController.view.frame = self.view.frame
            fromControllerSnapshot.removeFromSuperview()
            self.view.replaceSubview(toControllerSnapshot, with: toViewController.view)
            toViewController.view.frame = self.view.bounds
        }
     
        // Animation Group
        NSAnimationContext.beginGrouping()
        
        NSAnimationContext.current.duration = animationDuration
        
        fromControllerSnapshot.animator().frame = fromViewControllerToFrame
        toControllerSnapshot.animator().frame = self.view.bounds
        
        NSAnimationContext.endGrouping()
    }
    fileprivate let animationDuration : TimeInterval = 0.3
}
