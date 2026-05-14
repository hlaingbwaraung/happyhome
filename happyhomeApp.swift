//
//  happyhomeApp.swift
//  happyhome
//
//  Created by ライ ブワーアウン on 2026/04/26.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

@main
struct happyhomeApp: App {
    init() {
        #if os(macOS)
        NSApplication.shared.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            NSApplication.shared.windows.first?.makeKeyAndOrderFront(nil)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AuthGateView()
        }
    }
}
