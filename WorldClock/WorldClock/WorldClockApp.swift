//
//  WorldClockApp.swift
//  WorldClock
//
//  Created by Marius on 22/3/26.
//

import SwiftUI

@main
struct WorldClockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 480, height: 600)
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
