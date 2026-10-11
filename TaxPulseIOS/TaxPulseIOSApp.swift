import SwiftUI

@main
struct TaxPulseIOSApp: App {
    @StateObject private var state = AppState()
    @StateObject private var auth = AuthStore()
    @StateObject private var updates = UpdateStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .environmentObject(auth)
                .environmentObject(updates)
        }
    }
}
