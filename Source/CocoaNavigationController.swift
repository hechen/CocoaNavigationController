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

extension CocoaNavigationController {
    public enum Operation : Int {
        case none
        case push
        case pop
    }
}

/*
 CocoaNavigationController is a UINavigationController alike component brought to Cocoa
 
 It manages a stack of cocoa view controllers and a navigation bar.
 It performs horizontal view transitions for pushed and popped views while keeping the navigation bar in sync.
 
 
 Under the hood:
 
 1. CocoaNavigation is a subclass of NSViewController, act as an container ViewController.
 2. So container viewController need a rootViewController to show something.
 3. Not the same as iOS's navigationController, we cannot make sure container-view's frame as it can be embeded in any windows which has arbitrary frame.
 
 */
public class CocoaNavigationController: NSViewController {
    
    weak open var delegate: CocoaNavigationControllerDelegate?

    public convenience init(frame frameRect: CGRect, rootViewController: NSViewController) {
        self.init(nibName: nil, bundle: nil)
        
        view = NSView(frame: frameRect)
        view.autoresizingMask = [.minXMargin, .minYMargin, .width, .maxXMargin, .maxYMargin, .height]

        viewControllers = [rootViewController]
        
        rootViewController.view.autoresizingMask = [.minXMargin, .minYMargin, .width, .maxXMargin, .maxYMargin, .height]
        rootViewController.view.frame = view.bounds

        view.addSubview(rootViewController.view)
    }
    
    // Uses a horizontal slide transition. Has no effect if the view controller is already in the stack.
    open func pushViewController(_ viewController: NSViewController, animated: Bool) {
        if isAnimating {
            return
        }
        
        viewController.navigationController = self
        
        let topViewController = self.topViewController
        
        viewControllers.append(viewController)
        
        transition(from: topViewController, to: self.topViewController, animated: animated)
    }
    
    /*
     @discussion:
     
     This method removes the top view controller from the stack and makes the new top of the stack the active view controller.
     If the view controller at the top of the stack is the root view controller, this method does nothing.
     In other words, you cannot pop the last item on the stack.
     */
    @discardableResult
    open func popViewController(animated: Bool) -> NSViewController? {
        if viewControllers.count == 1 {
            return nil
        }
        
        let poppedViewController = topViewController
        viewControllers = Array(viewControllers.dropLast())
        
        transition(from: poppedViewController, to: topViewController, animated: animated, operation: .pop)
        
        return poppedViewController
    }
    
    // Pops view controllers until the one specified is on top. Return the popped controllers.
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

        transition(from: topViewController, to: viewController, animated: animated, operation: .pop)
        
        // from viewcontroller.next to last
        var poppedViewControllers = [NSViewController]()
        for i in index+1..<viewControllers.count {
            poppedViewControllers.append(viewControllers[i])
        }
        viewControllers = Array(viewControllers.dropLast(viewControllers.count - index - 1))
        
        return poppedViewControllers
    }
    
    // Pop until there's only a single view controller left on the stack. Returns the popped controllers.
    open func popToRootViewController(animated: Bool) -> [NSViewController]? {
        return popToViewController(rootViewController, animated: animated)
    }

    
    // The current view controller stack.
    open private(set) var viewControllers = [NSViewController]()
    
    // Top of stack
    open var topViewController: NSViewController {
        return viewControllers.last!
    }
    
    // Bottom of stack
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
        
        delegate?.navigationController(self, willShow: toViewController, animated: animated)
        
        toViewController.view.autoresizingMask = view.autoresizingMask
        
        var fromViewControllerToFrame = view.bounds
        var toViewControllerFromFrame = view.bounds

        if !animated {
            fromViewController.view.removeFromSuperview()
            toViewController.view.frame = view.bounds
            view.addSubview(toViewController.view)
            
            delegate?.navigationController(self, didShow: toViewController, animated: animated)
            
            return
        }
        
        // animate frame change
        switch operation {
        case .push:
            // toViewController from right to left.
            fromViewControllerToFrame.origin.x = -view.frame.size.width
            toViewControllerFromFrame.origin.x = view.frame.size.width
            
        case .pop:
            /// Pop fromViewController, offset width to the right.
            fromViewControllerToFrame.origin.x = view.frame.size.width
            toViewControllerFromFrame.origin.x = -view.frame.size.width
            
        case .none: break
        }
        
        
        toViewController.view.frame = toViewControllerFromFrame
        fromViewController.view.removeFromSuperview()
        
        let fromControllerSnapshot = NSImageView(frame: view.bounds)
        let toControllerSnapshot = NSImageView(frame: toViewControllerFromFrame)
        
        fromControllerSnapshot.image = fromViewController.view.snapshot()
        toControllerSnapshot.image = toViewController.view.snapshot()
        
        view.addSubview(fromControllerSnapshot)
        view.addSubview(toControllerSnapshot)
        
        
        // Do something after animation completes.
        NSAnimationContext.current.completionHandler = {
            toViewController.view.frame = self.view.frame
            fromControllerSnapshot.removeFromSuperview()
            
            self.view.replaceSubview(toControllerSnapshot, with: toViewController.view)
            
            self.delegate?.navigationController(self, didShow: toViewController, animated: animated)
            
            toViewController.view.frame = self.view.bounds
        }
        
        
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = animationDuration
        
        fromControllerSnapshot.animator().frame = fromViewControllerToFrame
        toControllerSnapshot.animator().frame = view.bounds
        
        NSAnimationContext.endGrouping()
        
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.isAnimating = false
        }
    }
    
    fileprivate let animationDuration : TimeInterval = 0.3
    fileprivate var isAnimating: Bool = false
}
