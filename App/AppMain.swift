// App entry point - shared by Xcode project and SwiftPM executable

import SwiftUI
import ModelExplorerApp

@main
struct ModelExplorerMain: App {
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
