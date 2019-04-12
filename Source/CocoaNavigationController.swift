//
//  CocoaNavigationController.swift
//  CocoaNavigationController
//
//  Created by chen he on 2019/4/2.
//  Copyright © 2019 chen he. All rights reserved.
//


import Cocoa

public protocol CocoaNavigationControllerDelegate : NSObjectProtocol {
    // Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
    func navigationController(_ navigationController: CocoaNavigationController, willShow viewController: NSViewController, animated: Bool)
    func navigationController(_ navigationController: CocoaNavigationController, didShow viewController: NSViewController, animated: Bool)
}

/*
 CocoaNavigationController is a UINavigationController alike component brought to Cocoa
 
 It manages a stack of cocoa view controllers and a navigation bar.
 It performs horizontal view transitions for pushed and popped views while keeping the navigation bar in sync.
 */
extension CocoaNavigationController {
    public enum Operation : Int {
        case none
        case push
        case pop
    }
}

public class CocoaNavigationController: NSViewController {
    
    weak open var delegate: CocoaNavigationControllerDelegate?

    // Convenience method pushes the root view controller without animation.
    // You must specify frame, since there may no window to attach.
    public convenience init(frame frameRect: CGRect, rootViewController: NSViewController?) {
        self.init(nibName: nil, bundle: nil)
        
        self.view = NSView(frame: frameRect)
        self.view.autoresizingMask = [.minXMargin, .minYMargin, .width, .maxXMargin, .maxYMargin, .height]
        
        var viewController: NSViewController
        if rootViewController == nil {
            viewController = NSViewController()
            viewController.view = NSView(frame: frameRect)
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
        
        viewController.navigationController = self
        
        let topViewController = self.topViewController
        
        viewControllers.append(viewController)
        
        transition(from: topViewController, to: self.topViewController, animated: animated)
    }
    
    // Returns the popped controller.
    @discardableResult
    open func popViewController(animated: Bool) -> NSViewController? {
        // rootViewController is not allowed to pop
        if viewControllers.count == 1 {
            return nil
        }
        
        // last view controller
        let poppedViewController = self.topViewController
        viewControllers = Array(viewControllers.dropLast())
        
        transition(from: poppedViewController, to: self.topViewController, animated: animated, operation: .pop)
        
        return poppedViewController
    }
    
    // Pops view controllers until the one specified is on top. Returns the popped controllers.
    @discardableResult
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
        viewControllers = Array(viewControllers.dropLast(viewControllers.count - index - 1))

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
        Arrange from and to horizontally. Then slide the whole one from left for Push, right for Pop
     
                        Push
     ◀─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
     ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐ ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
     
     │                   │ │                   │
     
     │                   │ │                   │
     
     │       From        │ │        To         │
     
     │                   │ │                   │
     
     │                   │ │                   │
     
     └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ▶
                        Pop
     */
    private func transition(from fromViewController: NSViewController,
                            to toViewController: NSViewController,
                            animated: Bool, operation: Operation = .push) {
        
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
        case .push:
            // toViewController from right to left.
            fromViewControllerToFrame.origin.x = -self.view.frame.size.width
            toViewControllerFromFrame.origin.x = self.view.frame.size.width
            
        case .pop:
            /// Pop fromViewController, offset width to the right.
            fromViewControllerToFrame.origin.x = self.view.frame.size.width
            toViewControllerFromFrame.origin.x = -self.view.frame.size.width
            
        case .none: break
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
            
            self.delegate?.navigationController(self, didShow: toViewController, animated: animated)
            
            toViewController.view.frame = self.view.bounds
        }
        
        delegate?.navigationController(self, willShow: toViewController, animated: animated)
     
        // Animation Group
        NSAnimationContext.beginGrouping()
        
        NSAnimationContext.current.duration = animationDuration
        
        fromControllerSnapshot.animator().frame = fromViewControllerToFrame
        toControllerSnapshot.animator().frame = self.view.bounds
        
        NSAnimationContext.endGrouping()
    }
    fileprivate let animationDuration : TimeInterval = 0.3
}
