//
//  NSView+Snapshot.swift
//  CocoaNavigationController
//
//  Created by Chen He on 2019/4/2.
//  Updated for Swift 5.9+
//

import Cocoa

public extension NSView {
    /// Creates a snapshot image of the view
    /// - Returns: An NSImage representing the current view contents
    func snapshot() -> NSImage? {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: bitmapRep)
        
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
}
