//
//  SolidusApp.swift
//  Solidus
//
//  Created by Justin Nipper on 7/17/21.
//

import SwiftUI

@main
struct SolidusApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
