import SwiftUI

struct EffectsV2View: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    
    @State var showPro = true
    @State var showPaywall = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    private var header: some View {
        HStack(spacing: 6) {
            Text("Pika AI")
                .font(.appFont(.Title2Emphasized))
                .foregroundStyle(.white)
            Spacer()
            Button {
                showPaywall = true
            } label: {
                Image("ProButton")//make it button
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 32)
            }
            
                .disabled(source.proSubscription == true)
                .opacity(source.proSubscription ? 0 : 1)
            
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
    
    var body: some View {
        ZStack {
            Color.bgSecond.ignoresSafeArea()
            Color.bgMain.ignoresSafeArea()
                .padding(.top, safeAreaInsets.top)
            VStack(spacing: 0) {
                header
                EffectsV2List(categories: source.categoriesArray)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
        .toolbar(.hidden)
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(show: $showPaywall)
            }
            .onAppear {
                if showPro != source.proSubscription {
                    showPro = source.proSubscription
                }
            }
            .onReceive(source.purchaseSubscriptionPublisher) {_ in
                showPro = source.proSubscription
            }
    }
}

#Preview {
    EffectsV2View()
        .environmentObject(Source())
        .environmentObject(EffectsV2Router())
}
