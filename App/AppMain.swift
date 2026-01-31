// App entry point for Xcode builds
// This file is compiled by Xcode directly, not part of SwiftPM

import SwiftUI
import ModelExplorerApp

@main
struct ModelExplorerXcode: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.automatic)
        .defaultSize(width: 700, height: 600)
        #endif
    }
}
