import XCTest
@testable import CocoaNavigationController

@MainActor
final class CocoaNavigationControllerTests: XCTestCase {
    
    // MARK: - Test Helpers
    
    func makeViewController() -> NSViewController {
        let vc = NSViewController()
        vc.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        return vc
    }
    
    // MARK: - Initialization Tests
    
    func testInitWithRootViewController() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        
        XCTAssertEqual(navController.viewControllers.count, 1)
        XCTAssertEqual(navController.topViewController, rootVC)
        XCTAssertEqual(navController.rootViewController, rootVC)
        XCTAssertEqual(rootVC.navigationController, navController)
    }
    
    func testInitialState() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        
        XCTAssertFalse(navController.isAnimating)
        XCTAssertEqual(navController.animationDuration, 0.3)
    }
    
    // MARK: - Push Tests
    
    func testPushViewController() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view // Load view
        
        let newVC = makeViewController()
        navController.push(newVC, animated: false)
        
        XCTAssertEqual(navController.viewControllers.count, 2)
        XCTAssertEqual(navController.topViewController, newVC)
        XCTAssertEqual(navController.rootViewController, rootVC)
        XCTAssertEqual(newVC.navigationController, navController)
    }
    
    func testPushMultipleViewControllers() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let vc1 = makeViewController()
        let vc2 = makeViewController()
        let vc3 = makeViewController()
        
        navController.push(vc1, animated: false)
        navController.push(vc2, animated: false)
        navController.push(vc3, animated: false)
        
        XCTAssertEqual(navController.viewControllers.count, 4)
        XCTAssertEqual(navController.topViewController, vc3)
        XCTAssertEqual(navController.rootViewController, rootVC)
    }
    
    func testPushSameViewControllerTwice() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let vc = makeViewController()
        navController.push(vc, animated: false)
        navController.push(vc, animated: false) // Should be ignored
        
        XCTAssertEqual(navController.viewControllers.count, 2)
    }
    
    // MARK: - Pop Tests
    
    func testPopViewController() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let newVC = makeViewController()
        navController.push(newVC, animated: false)
        
        let poppedVC = navController.pop(animated: false)
        
        XCTAssertEqual(poppedVC, newVC)
        XCTAssertEqual(navController.viewControllers.count, 1)
        XCTAssertEqual(navController.topViewController, rootVC)
        XCTAssertNil(newVC.navigationController)
    }
    
    func testPopRootViewControllerReturnsNil() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let poppedVC = navController.pop(animated: false)
        
        XCTAssertNil(poppedVC)
        XCTAssertEqual(navController.viewControllers.count, 1)
    }
    
    func testPopToViewController() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let vc1 = makeViewController()
        let vc2 = makeViewController()
        let vc3 = makeViewController()
        
        navController.push(vc1, animated: false)
        navController.push(vc2, animated: false)
        navController.push(vc3, animated: false)
        
        let poppedVCs = navController.popToViewController(vc1, animated: false)
        
        XCTAssertEqual(poppedVCs?.count, 2)
        XCTAssertTrue(poppedVCs?.contains(vc2) ?? false)
        XCTAssertTrue(poppedVCs?.contains(vc3) ?? false)
        XCTAssertEqual(navController.viewControllers.count, 2)
        XCTAssertEqual(navController.topViewController, vc1)
    }
    
    func testPopToRootViewController() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let vc1 = makeViewController()
        let vc2 = makeViewController()
        
        navController.push(vc1, animated: false)
        navController.push(vc2, animated: false)
        
        let poppedVCs = navController.popToRootViewController(animated: false)
        
        XCTAssertEqual(poppedVCs?.count, 2)
        XCTAssertEqual(navController.viewControllers.count, 1)
        XCTAssertEqual(navController.topViewController, rootVC)
    }
    
    func testPopToNonExistentViewControllerReturnsNil() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let vc1 = makeViewController()
        navController.push(vc1, animated: false)
        
        let nonExistentVC = makeViewController()
        let poppedVCs = navController.popToViewController(nonExistentVC, animated: false)
        
        XCTAssertNil(poppedVCs)
        XCTAssertEqual(navController.viewControllers.count, 2)
    }
    
    // MARK: - Set View Controllers Tests
    
    func testSetViewControllers() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let vc1 = makeViewController()
        let vc2 = makeViewController()
        let vc3 = makeViewController()
        
        navController.setViewControllers([vc1, vc2, vc3], animated: false)
        
        XCTAssertEqual(navController.viewControllers.count, 3)
        XCTAssertEqual(navController.topViewController, vc3)
        XCTAssertEqual(navController.rootViewController, vc1)
    }
    
    func testSetEmptyViewControllersIsIgnored() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        navController.setViewControllers([], animated: false)
        
        XCTAssertEqual(navController.viewControllers.count, 1)
        XCTAssertEqual(navController.topViewController, rootVC)
    }
    
    // MARK: - Navigation Controller Reference Tests
    
    func testNavigationControllerReference() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        XCTAssertEqual(rootVC.navigationController, navController)
        
        let newVC = makeViewController()
        navController.push(newVC, animated: false)
        XCTAssertEqual(newVC.navigationController, navController)
        
        navController.pop(animated: false)
        XCTAssertNil(newVC.navigationController)
    }
    
    // MARK: - Delegate Tests
    
    func testDelegateWillShowCalled() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let delegateMock = NavigationDelegateMock()
        navController.delegate = delegateMock
        
        let newVC = makeViewController()
        navController.push(newVC, animated: false)
        
        XCTAssertEqual(delegateMock.willShowCount, 1)
        XCTAssertEqual(delegateMock.lastWillShowVC, newVC)
    }
    
    func testDelegateDidShowCalled() {
        let rootVC = makeViewController()
        let navController = CocoaNavigationController(rootViewController: rootVC)
        _ = navController.view
        
        let delegateMock = NavigationDelegateMock()
        navController.delegate = delegateMock
        
        let newVC = makeViewController()
        navController.push(newVC, animated: false)
        
        XCTAssertEqual(delegateMock.didShowCount, 1)
        XCTAssertEqual(delegateMock.lastDidShowVC, newVC)
    }
    
    // MARK: - Snapshot Tests
    
    func testViewSnapshot() {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
        
        let snapshot = view.snapshot()
        
        XCTAssertNotNil(snapshot)
        XCTAssertEqual(snapshot?.size, view.bounds.size)
    }
    
    // MARK: - Navigation Operation Tests
    
    func testNavigationOperationValues() {
        XCTAssertEqual(NavigationOperation.none.rawValue, 0)
        XCTAssertEqual(NavigationOperation.push.rawValue, 1)
        XCTAssertEqual(NavigationOperation.pop.rawValue, 2)
    }
}

// MARK: - Test Helpers

@MainActor
final class NavigationDelegateMock: CocoaNavigationControllerDelegate {
    var willShowCount = 0
    var didShowCount = 0
    var lastWillShowVC: NSViewController?
    var lastDidShowVC: NSViewController?
    
    func navigationController(_ navigationController: CocoaNavigationController, willShow viewController: NSViewController, animated: Bool) {
        willShowCount += 1
        lastWillShowVC = viewController
    }
    
    func navigationController(_ navigationController: CocoaNavigationController, didShow viewController: NSViewController, animated: Bool) {
        didShowCount += 1
        lastDidShowVC = viewController
    }
}
