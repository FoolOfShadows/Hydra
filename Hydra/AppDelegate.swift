//
//  AppDelegate.swift
//  Hydra
//
//  Created by Fool on 2/6/19.
//  Copyright © 2019 Fool. All rights reserved.
//
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Checks if user system is Dark Mode capable and sets
        // the app to Light Mode if it is
        // FIXME: Doing this because I don't have the text fields in the various
        // modules set up to correctly handle dark mode.
        if #available(macOS 10.14, *) {
            NSApp.appearance = NSAppearance(named: .aqua)
        }
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

