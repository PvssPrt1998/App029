import SwiftUI
import StoreKit

struct OnboardingView: View {
    @State var selection = 0
    //@Environment(\.safeAreaInsets) private var safeAreaInsets
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            TabView(selection: $selection) {
                onboardingImage("onboarding1")
                    .tag(0)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding2")
                    .tag(1)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding3")
                    .tag(2)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding4")
                    .tag(3)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("onboarding5")
                    .tag(4)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            .gesture(DragGesture())
            .overlay(
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text(titleForSelection)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text(descriptionForSelection)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16))
                    
                    VStack(spacing: 16) {
                        
                        if selection == 0 || selection == 1 || selection == 2 {
                            Button {
                                withAnimation {
                                    selection += 1
                                }
                            } label: {
                                Text("Continue")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.textTertiary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.cSecondary)
                                    .clipShape(.rect(cornerRadius: 8))
                            }
                            .padding(.horizontal, 16)
                        } else if selection == 3 {
                            HStack(spacing: 8) {
                                Button {
                                    withAnimation {
                                        selection += 1
                                    }
                                } label: {
                                    Text("Later")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.bgLight)
                                        .clipShape(.rect(cornerRadius: 8))
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
                                    withAnimation {
                                        selection += 1
                                    }
                                } label: {
                                    Text("Rate!")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(.textTertiary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.cSecondary)
                                        .clipShape(.rect(cornerRadius: 8))
                                }
                                
                            }
                            .padding(.horizontal, 16)
                        } else {
                            Button {
                                withAnimation {
                                    showOnboarding = false
                                }
                            } label: {
                                Text("Start")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.textTertiary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.cSecondary)
                                    .clipShape(.rect(cornerRadius: 8))
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        indicators
                        
                    }
                }
                
                ,alignment: .bottom
            )
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    private func onboardingImage(_ title: String) -> some View {
        Image(title)
            .resizable()
            .scaledToFit()
            //.padding(EdgeInsets(top: 0, leading: 16, bottom: 250, trailing: 16))
            .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var indicators: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(selection == 0 ? Color.cSecondary : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 1 ? Color.cSecondary : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 2 ? Color.cSecondary : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 3 ? Color.cSecondary : Color.white.opacity(0.2))
            Circle()
                .fill(selection == 4 ? Color.cSecondary : Color.white.opacity(0.2))
        }
        .frame(height: 8)
    }
    
    private var titleForSelection: String {
        switch selection {
        case 0: return "Transform Photos with\nFun"
        case 1: return "Unleash Fun Creative\nEffects"
        case 2: return "Instant Results, Every\nTime"
        case 3: return "Rate our app in the\nAppStore"
        case 4: return "Start creating right\nnow!"
        default: return "Don't miss new trends ⭐"
        }
    }
    
    private var descriptionForSelection: String {
        switch selection {
        case 0: return "Easily apply creative effects to your photos\nwith just a tap"
        case 1: return "Squish, explode, crash, and more – unleash\nyour creativity!"
        case 2: return "Just choose an effect and watch your photo\ncome to life!"
        case 3: return "Help us grow up, share the app with your\nfriends"
        case 4: return "Discover a world of amazing effects. Surprise\nyour friends, surprise yourself"
        default: return "Allow notifications"
        }
    }
}
