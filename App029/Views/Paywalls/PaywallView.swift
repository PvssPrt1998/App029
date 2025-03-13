
import SwiftUI
import ApphudSDK

struct PaywallView: View {
    
    @Binding var show: Bool
    @Environment(\.openURL) var openURL
    @EnvironmentObject var source: Source
    @State var isYear = true
    @State var showClose = false
    
    var body: some View {
        ZStack {
            Color.bgPaywall.ignoresSafeArea()
            
            Image("PaywallImage")
                .scaledToFit()
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                title
                purposeList
                selection
                bottomBar
                    .padding(.horizontal, 16)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            
            Button {
                withAnimation {
                    show = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.32))
                    .clipShape(.rect(cornerRadius: 10))
            }
            .opacity(showClose ? 1 : 0)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                showClose = true
            }
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Button {
                source.startPurchase(product: isYear ? source.purchaseManager.productsApphud[1] : source.purchaseManager.productsApphud[0]) { bool in
                    if bool {
                        print("Subscription purchased")
                        source.proSubscription = true
                        self.source.networking.fetchCurrentTokens(apphudId: userID) { tokens in
                            print("Available tokens \(tokens)")
                            self.source.tokens = tokens
                            withAnimation {
                                show = false
                            }
                        } errorHandler: {
                            
                        }
                    }
                    withAnimation {
                        show = false
                    }
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(.cSecondary)
                    .clipShape(.rect(cornerRadius: 8))
            }
            .padding(.vertical, 2)
            
            HStack(spacing: 12) {
                Button {
                    if let url = URL(string: "https://docs.google.com/document/d/1Bzr1G22pUKtzDY6VxoiaMAHtEqgTSpYbuXhtMZ4I-Cw/edit?usp=sharing") {
                        openURL(url)
                    }
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
                Button {
                    source.restorePurchase { bool in
                        if bool {
                            source.proSubscription = false
                            show = false
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Button {
                    if let url = URL(string: "https://docs.google.com/document/d/13JXlS7pZorpyb5H5V6nCiATAVDWDyenf0wSs3KRGQf4/edit?usp=sharing") {
                        openURL(url)
                    }
                } label: {
                    Text("Terms of Use")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 12, trailing: 0))
        }
    }
    
    private var title: some View {
        Text("Unlock Pika Premium")
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
    }
    
    private var selection: some View {
        VStack(spacing: 8) {
            yearly
            week
        }
        .padding(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
    }
    
    private var yearly: some View {
        HStack {
            VStack(spacing: 2) {
                Text(source.purchaseManager.returnName(product: source.purchaseManager.productsApphud[0]))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(source.purchaseManager.returnPriceSign(product: source.purchaseManager.productsApphud[0]) + source.purchaseManager.returnPrice(product: source.purchaseManager.productsApphud[0]))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Save 84%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.textTertiary)
                    .frame(width: 75, height: 24)
                    .background(Color.cSecondary)
                    .clipShape(.rect(cornerRadius: 4))
                
                Text("🔥 \(source.purchaseManager.returnPriceSign(product: source.purchaseManager.productsApphud[0]))" + "\(pricePerWeek() ?? 0)" + "/per week 🔥")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white)
            }
            
        }
        .frame(height: 64)
        .padding(.horizontal, 16)
        .background(Color.bgLight)
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isYear ? Color.cSecondary : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            isYear = true
        }
    }
    
    func pricePerWeek() -> Double? {
        guard let price = Double(String(format: "%.2f", getSubscriptionPrice(for: source.purchaseManager.productsApphud[0]) / 52)) else { return nil }
        return price
    }
                     
     private func getSubscriptionPrice(for product: ApphudProduct) -> Double {
         if let price = product.skProduct?.price {
             return Double(truncating: price)
         } else {
             return 0
         }
     }
    
    private var purposeList: some View {
        HStack(spacing: 8) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(height: 22)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(height: 22)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(height: 22)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(height: 22)
            }
            VStack(alignment: .leading, spacing: 16) {
                Text("Unlimited Video Generations")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(height: 22)
                Text("Ad-Free Experience")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(height: 22)
                Text("High-Quality Video Output")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(height: 22)
                Text("Access to All Effects")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(height: 22)
            }
        }
        .frame(width: 350)
    }
    
    private var week: some View {
        HStack {
            Text(source.purchaseManager.returnName(product: source.purchaseManager.productsApphud[1]))
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(source.purchaseManager.returnPriceSign(product: source.purchaseManager.productsApphud[1]) + source.purchaseManager.returnPrice(product: source.purchaseManager.productsApphud[1]))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color.bgLight)
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(!isYear ? Color.cSecondary : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            isYear = false
        }
    }
}

#Preview {
    //PaywallView()
}
