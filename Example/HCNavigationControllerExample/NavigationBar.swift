//
//  NavigationBar.swift
//  HCNavigationControllerExample
//
//  Created by chen he on 2019/4/3.
//  Copyright © 2019 chen he. All rights reserved.
//

import Cocoa

class NavigationBar: NSView {
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    
    
    var title: String {
        set {
            titleLabel.stringValue = newValue
        }
        get {
            return titleLabel.stringValue
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}

extension NavigationBar {
    
    // Default nib name must be same as class name
    static var nibName: String {
        return String(describing: NavigationBar.self)
    }
    
    static func createFromNib(in bundle: Bundle = Bundle.main) -> NavigationBar {
        var topLevelArray: NSArray? = nil
        bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
        let views = Array<Any>(topLevelArray!).filter { $0 is NavigationBar }
        return views.last as! NavigationBar
    }
}
