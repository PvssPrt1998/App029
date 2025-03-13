import SwiftUI
import SystemConfiguration

struct ContentView: View {
    
    @State var showInternetAlert = false
    
    @ObservedObject private var router = EffectsV2Router()
    
    @AppStorage("showOnboarding") var showOnboarding = true
    
    var body: some View {
        content
            .onAppear {
                if !isInternetAvailable() {
                    showInternetAlert = true
                }
            }
            .alert("Error", isPresented: $showInternetAlert) {
                Button("Try again", role: .cancel) {
                    showInternetAlert = false
                    if !isInternetAvailable() {
                        showInternetAlert = true
                    }
                }
            } message: {
                Text("No internet connection")
            }
    }
    
    @ViewBuilder var content: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            Tab()
                .environmentObject(router)
        }
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}

#Preview {
    ContentView()
        .environmentObject(Source())
}
