import SwiftUI
import StoreKit


struct SettingsView: View {
    
    @EnvironmentObject var source: Source
    @Environment(\.openURL) var openURL
    @State var tokens = 0
    
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    var body: some View {
        ZStack {
            Color
                .bgSecond
                .ignoresSafeArea()
            VStack(spacing: 0) {
                header
                    .background(Color.bgMain)
                
                content
                    .background(Color.bgMain)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
        .onReceive(source.tokenPublisher) { output in
            tokens = source.tokens
        }
        .fullScreenCover(isPresented: $showPaywallToken) {
            TokensPaywall(show: $showPaywallToken)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
    
    private var header: some View {
        HStack {
            Text("Settings")
                .font(.appFont(.Title2Emphasized))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                showPaywall = true
            } label: {
                Image("ProButton")//make it button
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
    
    private var content: some View {
        VStack(spacing: 4) {
            Button {
                 showPaywallToken = true
            } label: {
                button(imageTitle: "star.circle.fill", title: "Tokens to generate")
            }
            .overlay(
                Text("\(tokens)")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                ,alignment: .trailing
            )
            
            Button {
                if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSd1OW3z5XvJJDVoMzjjMA-yw7BfVx_eW33ZoZpO9_c6i01e6g/viewform?usp=dialog") {
                    openURL(url)
                }
            } label: {
                button(imageTitle: "star.circle.fill", title: "Contact us")
            }
            .padding(.top, 12)
            Button {
                 share()
            } label: {
                button(imageTitle: "star.circle.fill", title: "Share the app")
            }
            Button {
                guard let url = URL(string: "itms-apps://itunes.apple.com/app/id6739883934?action=write-review") else { //как пример - 6737510164
                    return
                }
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Unable to open App Store")
                }
            } label: {
                button(imageTitle: "star.circle.fill", title: "Rate the app")
            }
            
            Button {
                if let url = URL(string: "https://docs.google.com/document/d/13JXlS7pZorpyb5H5V6nCiATAVDWDyenf0wSs3KRGQf4/edit?usp=sharing") {
                    openURL(url)
                }
            } label: {
                button(imageTitle: "star.circle.fill", title: "Usage policy")
            }
            .padding(.top, 12)
            Button {
                if let url = URL(string: "https://docs.google.com/document/d/1Bzr1G22pUKtzDY6VxoiaMAHtEqgTSpYbuXhtMZ4I-Cw/edit?usp=sharing") {
                    openURL(url)
                }
            } label: {
                button(imageTitle: "star.circle.fill", title: "Privacy policy")
            }
        }
        .padding(16)
    }
    
    func share() {
        let urlStr = "https://apps.apple.com/app/id6739883934"
        guard let urlShare = URL(string: urlStr)  else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        if #available(iOS 15.0, *) {
            UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController?
            .present(activityVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func button(imageTitle: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: imageTitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgLight)
        .clipShape(.rect(cornerRadius: 8))
    }
    
}
