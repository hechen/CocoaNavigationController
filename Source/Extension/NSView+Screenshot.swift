//
//  NSView+Screenshot.swift
//  HCNavigationController
//
//  Created by chen he on 2019/4/2.
//

import Cocoa

extension NSView {
    func snapshot() -> NSImage? {
        // Returns a bitmap-representation object suitable for caching the specified portion of the view.
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage()
        image.addRepresentation(bitmapRep)
        bitmapRep.size = bounds.size
        return image
    }
}
