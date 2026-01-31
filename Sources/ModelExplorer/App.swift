import SwiftUI

public struct ModelExplorerApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.automatic)
        .defaultSize(width: 700, height: 600)
        #endif
    }
}
