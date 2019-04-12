//
//  NSViewController+HCNavigationController.swift
//  HCNavigationController
//
//  Created by chen he on 2019/4/2.
//

import Cocoa

private var COCOANAVIGATIONCONTROLLER_PROPERTY = 0
public extension NSViewController {
    var navigationController: CocoaNavigationController? {
        get {
            return objc_getAssociatedObject(self, &COCOANAVIGATIONCONTROLLER_PROPERTY) as? CocoaNavigationController
        }
        set {
            objc_setAssociatedObject(self, &COCOANAVIGATIONCONTROLLER_PROPERTY, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
