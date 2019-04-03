//
//  TestViewController.swift
//  HCNavigationControllerExample
//
//  Created by chen he on 2019/4/2.
//  Copyright © 2019 chen he. All rights reserved.
//

import Cocoa

class TestViewController: NSViewController {

    @IBOutlet weak var randomLabel: NSTextField!
    
    var navigationBar: NavigationBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = formatter.string(from: Date())
        randomLabel.stringValue = date
        
        view.backgroundColor = [NSColor.red, NSColor.blue, .green, .gray, .yellow].randomElement()

//        navigationBar = NavigationBar.createFromNib()
//        if navigationBar != nil {
//            navigationBar!.frame = NSRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44)
//            view.addSubview(navigationBar!)
//        }
//        
//        navigationBar?.backButton.target = self
//        navigationBar?.backButton.action = #selector(backButtonAction(_:))
//        navigationBar?.backgroundColor = .white
//        navigationBar?.title = date
//        navigationBar?.backButton.imagePosition = .imageLeft
    }
}


extension TestViewController {
    @objc
    func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
private extension NSView {
    var backgroundColor: NSColor? {
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
        get {
            guard let cgColor = layer?.backgroundColor else { return .clear }
            return NSColor(cgColor: cgColor)
        }
    }
}
