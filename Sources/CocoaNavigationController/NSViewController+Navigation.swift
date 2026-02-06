//
//  NSViewController+Navigation.swift
//  CocoaNavigationController
//
//  Created by Chen He on 2019/4/2.
//  Updated for Swift 5.9+
//

import Cocoa

private var navigationControllerKey: UInt8 = 0

public extension NSViewController {
    /// The navigation controller that contains this view controller, if any
    var navigationController: CocoaNavigationController? {
        get {
            objc_getAssociatedObject(self, &navigationControllerKey) as? CocoaNavigationController
        }
        set {
            objc_setAssociatedObject(
                self,
                &navigationControllerKey,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN  // Weak reference to avoid retain cycle
            )
        }
    }
}
