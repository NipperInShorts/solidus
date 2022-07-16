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
    let menu = NSMenu()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        setupMenu()
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        let item = NSMenuItem(title: "Quit", action: #selector(terminateApp), keyEquivalent: "Q")
        menu.addItem(item)
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
            statusButton.action = #selector(handleStatusBarClick(sender:))
            statusButton.target = self
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    @objc func terminateApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func handleStatusBarClick(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            if popover.isShown {
                hidePopover(sender)
            }
            statusItem.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            togglePopover(sender)
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
