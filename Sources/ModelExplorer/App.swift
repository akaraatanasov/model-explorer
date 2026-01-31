import SwiftUI

@main
struct ModelExplorerApp: App {
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
