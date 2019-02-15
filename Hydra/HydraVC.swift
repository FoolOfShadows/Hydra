//
//  ViewController.swift
//  Hydra
//
//  Created by Fool on 2/6/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

protocol ShowMainWindowDelegate: class {
    func seriouslyShowTheWindow()
}

class HydraVC: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(seriouslyShowTheWindow), name: Notification.Name( "ShowMainWindow"), object: nil)
    }
    
    @IBAction func showMainWindow(_ sender: NSMenuItem) {
        print("Being told to show the main window")
        seriouslyShowTheWindow()
        //self.view.window?.makeKeyAndOrderFront(nil)
        //self.view.window?.makeKeyAndOrderFront(nil)
    }
    @objc func seriouslyShowTheWindow() {
        print("In the serious window func")
        self.view.window?.makeKeyAndOrderFront(nil)
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

