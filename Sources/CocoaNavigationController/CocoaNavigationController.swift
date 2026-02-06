//
//  CocoaNavigationController.swift
//  CocoaNavigationController
//
//  Created by Chen He on 2019/4/2.
//  Updated for Swift 5.9+ with modern patterns
//

import Cocoa

/// Delegate protocol for navigation controller events
@MainActor
public protocol CocoaNavigationControllerDelegate: AnyObject {
    /// Called before a view controller is shown
    func navigationController(_ navigationController: CocoaNavigationController, willShow viewController: NSViewController, animated: Bool)
    
    /// Called after a view controller is shown
    func navigationController(_ navigationController: CocoaNavigationController, didShow viewController: NSViewController, animated: Bool)
}

/// Default implementations (optional delegate methods)
public extension CocoaNavigationControllerDelegate {
    func navigationController(_ navigationController: CocoaNavigationController, willShow viewController: NSViewController, animated: Bool) {}
    func navigationController(_ navigationController: CocoaNavigationController, didShow viewController: NSViewController, animated: Bool) {}
}

/// Navigation operation type
public enum NavigationOperation: Int, Sendable {
    case none
    case push
    case pop
}

/// A container view controller that manages a stack of view controllers,
/// similar to UINavigationController on iOS.
///
/// Example usage:
/// ```swift
/// let rootVC = MyViewController()
/// let navController = CocoaNavigationController(rootViewController: rootVC)
///
/// // Push a new view controller
/// navController.push(anotherVC, animated: true)
///
/// // Pop back
/// navController.pop(animated: true)
/// ```
@MainActor
public final class CocoaNavigationController: NSViewController {
    
    // MARK: - Properties
    
    /// Delegate for navigation events
    public weak var delegate: CocoaNavigationControllerDelegate?
    
    /// The current view controller stack (read-only)
    public private(set) var viewControllers: [NSViewController] = []
    
    /// The view controller at the top of the stack
    public var topViewController: NSViewController? {
        viewControllers.last
    }
    
    /// The root view controller (bottom of stack)
    public var rootViewController: NSViewController? {
        viewControllers.first
    }
    
    /// Whether an animation is currently in progress
    public private(set) var isAnimating: Bool = false
    
    /// Animation duration for push/pop transitions
    public var animationDuration: TimeInterval = 0.3
    
    // MARK: - Initialization
    
    /// Creates a navigation controller with a root view controller
    /// - Parameter rootViewController: The initial view controller
    public convenience init(rootViewController: NSViewController) {
        self.init(nibName: nil, bundle: nil)
        viewControllers = [rootViewController]
        rootViewController.navigationController = self
    }
    
    public override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.autoresizingMask = [.width, .height]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add root view controller's view if present
        if let rootVC = rootViewController {
            addChildIfNeeded(rootVC)
            rootVC.view.frame = view.bounds
            rootVC.view.autoresizingMask = [.width, .height]
            view.addSubview(rootVC.view)
        }
    }
    
    public override func viewDidLayout() {
        super.viewDidLayout()
        topViewController?.view.frame = view.bounds
    }
    
    // MARK: - Navigation Methods
    
    /// Pushes a view controller onto the stack with an optional animation
    /// - Parameters:
    ///   - viewController: The view controller to push
    ///   - animated: Whether to animate the transition
    public func push(_ viewController: NSViewController, animated: Bool) {
        pushViewController(viewController, animated: animated)
    }
    
    /// Pushes a view controller onto the stack with an optional animation
    /// - Parameters:
    ///   - viewController: The view controller to push
    ///   - animated: Whether to animate the transition
    public func pushViewController(_ viewController: NSViewController, animated: Bool) {
        guard !isAnimating else { return }
        guard !viewControllers.contains(viewController) else { return }
        
        let fromVC = topViewController
        
        viewController.navigationController = self
        addChildIfNeeded(viewController)
        viewControllers.append(viewController)
        
        if let fromVC = fromVC {
            transition(from: fromVC, to: viewController, animated: animated, operation: .push)
        } else {
            viewController.view.frame = view.bounds
            viewController.view.autoresizingMask = [.width, .height]
            view.addSubview(viewController.view)
            delegate?.navigationController(self, didShow: viewController, animated: false)
        }
    }
    
    /// Pops the top view controller from the stack
    /// - Parameter animated: Whether to animate the transition
    /// - Returns: The popped view controller, or nil if stack has only one controller
    @discardableResult
    public func pop(animated: Bool) -> NSViewController? {
        popViewController(animated: animated)
    }
    
    /// Pops the top view controller from the stack
    /// - Parameter animated: Whether to animate the transition
    /// - Returns: The popped view controller, or nil if stack has only one controller
    @discardableResult
    public func popViewController(animated: Bool) -> NSViewController? {
        guard viewControllers.count > 1 else { return nil }
        guard !isAnimating else { return nil }
        
        let poppedVC = viewControllers.removeLast()
        
        if let toVC = topViewController {
            transition(from: poppedVC, to: toVC, animated: animated, operation: .pop)
        }
        
        return poppedVC
    }
    
    /// Pops to a specific view controller in the stack
    /// - Parameters:
    ///   - viewController: The target view controller
    ///   - animated: Whether to animate the transition
    /// - Returns: Array of popped view controllers, or nil if target not found
    @discardableResult
    public func popToViewController(_ viewController: NSViewController, animated: Bool) -> [NSViewController]? {
        guard let targetIndex = viewControllers.firstIndex(of: viewController) else { return nil }
        guard targetIndex < viewControllers.count - 1 else { return nil }
        guard !isAnimating else { return nil }
        
        let fromVC = topViewController!
        let poppedVCs = Array(viewControllers[(targetIndex + 1)...])
        viewControllers = Array(viewControllers[...targetIndex])
        
        transition(from: fromVC, to: viewController, animated: animated, operation: .pop)
        
        // Clean up popped controllers
        for vc in poppedVCs {
            vc.navigationController = nil
            vc.removeFromParent()
        }
        
        return poppedVCs
    }
    
    /// Pops to the root view controller
    /// - Parameter animated: Whether to animate the transition
    /// - Returns: Array of popped view controllers
    @discardableResult
    public func popToRootViewController(animated: Bool) -> [NSViewController]? {
        guard let rootVC = rootViewController else { return nil }
        return popToViewController(rootVC, animated: animated)
    }
    
    /// Sets the entire view controller stack
    /// - Parameters:
    ///   - viewControllers: The new view controller stack
    ///   - animated: Whether to animate the transition to the new top
    public func setViewControllers(_ viewControllers: [NSViewController], animated: Bool) {
        guard !viewControllers.isEmpty else { return }
        guard !isAnimating else { return }
        
        let oldTopVC = topViewController
        let oldVCs = self.viewControllers
        
        // Set new stack
        self.viewControllers = viewControllers
        for vc in viewControllers {
            vc.navigationController = self
            if vc.parent != self {
                addChildIfNeeded(vc)
            }
        }
        
        // Clean up old controllers not in new stack
        for vc in oldVCs where !viewControllers.contains(vc) {
            vc.navigationController = nil
            vc.removeFromParent()
        }
        
        // Transition if top changed
        if let newTopVC = topViewController, newTopVC !== oldTopVC {
            if let oldTopVC = oldTopVC {
                transition(from: oldTopVC, to: newTopVC, animated: animated, operation: .push)
            } else {
                newTopVC.view.frame = view.bounds
                newTopVC.view.autoresizingMask = [.width, .height]
                view.addSubview(newTopVC.view)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func transition(
        from fromVC: NSViewController,
        to toVC: NSViewController,
        animated: Bool,
        operation: NavigationOperation
    ) {
        delegate?.navigationController(self, willShow: toVC, animated: animated)
        
        toVC.view.autoresizingMask = [.width, .height]
        
        guard animated else {
            fromVC.view.removeFromSuperview()
            toVC.view.frame = view.bounds
            view.addSubview(toVC.view)
            
            if operation == .pop {
                fromVC.navigationController = nil
                fromVC.removeFromParent()
            }
            
            delegate?.navigationController(self, didShow: toVC, animated: false)
            return
        }
        
        // Calculate frames
        var fromEndFrame = view.bounds
        var toStartFrame = view.bounds
        
        switch operation {
        case .push:
            fromEndFrame.origin.x = -view.bounds.width
            toStartFrame.origin.x = view.bounds.width
        case .pop:
            fromEndFrame.origin.x = view.bounds.width
            toStartFrame.origin.x = -view.bounds.width
        case .none:
            break
        }
        
        // Create snapshots for smooth animation
        let fromSnapshot = NSImageView(frame: view.bounds)
        let toSnapshot = NSImageView(frame: toStartFrame)
        
        fromSnapshot.image = fromVC.view.snapshot()
        toSnapshot.image = toVC.view.snapshot()
        fromSnapshot.imageScaling = .scaleProportionallyUpOrDown
        toSnapshot.imageScaling = .scaleProportionallyUpOrDown
        
        // Remove original view and add snapshots
        fromVC.view.removeFromSuperview()
        view.addSubview(fromSnapshot)
        view.addSubview(toSnapshot)
        
        isAnimating = true
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            fromSnapshot.animator().frame = fromEndFrame
            toSnapshot.animator().frame = view.bounds
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                guard let self = self else { return }
                
                // Remove snapshots
                fromSnapshot.removeFromSuperview()
                toSnapshot.removeFromSuperview()
                
                // Add real view
                toVC.view.frame = self.view.bounds
                self.view.addSubview(toVC.view)
                
                // Clean up popped controller
                if operation == .pop {
                    fromVC.navigationController = nil
                    fromVC.removeFromParent()
                }
                
                self.isAnimating = false
                self.delegate?.navigationController(self, didShow: toVC, animated: true)
            }
        })
    }
    
    private func addChildIfNeeded(_ viewController: NSViewController) {
        if viewController.parent != self {
            addChild(viewController)
        }
    }
}
