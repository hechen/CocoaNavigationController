//
//  ViewController.swift
//  HCNavigationControllerExample
//
//  Created by chen he on 2019/4/2.
//  Copyright © 2019 chen he. All rights reserved.
//

import Cocoa
import HCNavigationController

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func showNavigationController(_ sender: Any) {
        
//        let window = NSApp.keyWindow
        
        // Do any additional setup after loading the view.

        self.navigationController = HCNavigationController(withFrame: NSApp.keyWindow!.frame, rootViewController: nil)
        
        let window = NSWindow(contentViewController: self.navigationController!)
        window.makeKeyAndOrderFront(nil)
    }
    
    
    @IBAction func Push(_ sender: Any) {
        let vc = TestViewController(nibName: "TestViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Pop(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

