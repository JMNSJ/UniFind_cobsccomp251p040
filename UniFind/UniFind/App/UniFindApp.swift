
import SwiftUI
import FirebaseCore

@main
struct UniFindApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .preferredColorScheme(.light)
        }
    }
}
