//
//  NSViewController+HCNavigationController.swift
//  HCNavigationController
//
//  Created by chen he on 2019/4/2.
//

import Cocoa

private var HCNAVIGATIONCONTROLLER_PROPERTY = 0
public extension NSViewController {
    var navigationController: HCNavigationController? {
        get {
            return objc_getAssociatedObject(self, &HCNAVIGATIONCONTROLLER_PROPERTY) as? HCNavigationController
        }
        set {
            objc_setAssociatedObject(self, &HCNAVIGATIONCONTROLLER_PROPERTY, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
