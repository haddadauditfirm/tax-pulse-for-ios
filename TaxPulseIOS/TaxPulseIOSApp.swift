import SwiftUI

@main
struct TaxPulseIOSApp: App {
    @StateObject private var state = AppState()
    @StateObject private var auth = AuthStore()
    @StateObject private var updates = UpdateStore()
    @StateObject private var remoteConfig = RemoteConfigStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .environmentObject(auth)
                .environmentObject(updates)
                .environmentObject(remoteConfig)
        }
    }
}
