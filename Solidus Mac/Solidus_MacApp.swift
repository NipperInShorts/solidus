//
//  Solidus_MacApp.swift
//  Solidus Mac
//
//  Created by Justin Nipper on 7/14/22.
//

import SwiftUI

@main
struct Solidus_MacApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
       WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        setupMenu()
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
    }
    
    func setupMenu() {
        popover.animates = true
        popover.contentSize = NSSize(width: 300, height: 300)
        popover.behavior = .transient
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: ContentView())
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let statusButton  = statusItem.button {
            statusButton.image = NSImage(named: NSImage.Name("BarIcon"))
            statusButton.action = #selector(togglePopover(_:))
            statusButton.target = self
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    func hidePopover(_ sender: AnyObject) {
        popover.performClose(sender)
    }
}
