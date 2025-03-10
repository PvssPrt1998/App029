import SwiftUI
import AVKit

struct PreviewFromCategoryView: View {
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route.CategoryListRoute.PreviewRoute
    let effect: Effect
    @State var player: AVPlayer
    
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    init(effect: Effect) {
        self.effect = effect
        if let localUrlStr = effect.localUrl, let url = URL(string: localUrlStr) {
           // print("Load local Preview from category")
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else if let urlStr = effect.previewSmall, let url = URL(string: urlStr) {
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else {
            self.player = AVPlayer()
        }
    }
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 8) {
                VideoPlayer(player: player)
                    .disabled(true)
                    .clipShape(.rect(cornerRadius: 8))
                    .onAppear { player.play() }
                    .onDisappear{ player.pause() }
                    .onReceive(NotificationCenter
                        .default
                        .publisher(
                            for: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem),
                               perform: { _ in
                                    player.seek(to: .zero)
                                    player.play()
                                }
                    )
                
                Button {
                    if effect.id == 86 || effect.id == 81 {
                        router.path.append(nextScreen.photoUploadDouble(effect))
                    } else {
                        router.path.append(nextScreen.photoUpload(effect))
                    }
                } label: {
                    Text("\(Image(systemName: "bolt.fill")) Use the effect")
                        .font(.appFont(.Title2Emphasized))
                        .foregroundStyle(.textTertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(height: 64)
                        .background(Color.cSecondary)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 27, trailing: 16))
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(effect.effect)
                    .font(.appFont(.BodyEmphasized))
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
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
        }
        .toolbarBackground(.bgSecond, for: .navigationBar)
        .onAppear {
            player.play()
        }
        .onDisappear {
            player.pause()
        }
        .fullScreenCover(isPresented: $showPaywallToken) {
            TokensPaywall(show: $showPaywallToken)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
}

#Preview {
    PreviewFromCategoryView(effect:
                    Effect(
        id: 1,
        ai: "pv",
        effect: "Popular",
        preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
        previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
    ))
        .environmentObject(EffectsV2Router())
}
