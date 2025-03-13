import SwiftUI
import AVKit

struct EffectsV2EffectCard: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route
    
    @State var player: AVPlayer
    @State var effect: Effect
    
    init(effect: Effect) {
        self.effect = effect
        self.player = AVPlayer()
    }
    
    var body: some View {
        Button {
            router.path.append(nextScreen.preview(effect))
        } label: {
            content
        }
        .onAppear {
            load()
        }
        .onDisappear {
            self.player.pause()
        }
    }
    
    func load() {
        if let localUrlStr = effect.localUrl, let url = URL(string: localUrlStr) {
            //print("Load local")
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            withAnimation {
                self.player = player
            }
        } else if let urlStr = effect.previewSmall, let url = URL(string: urlStr) {
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            withAnimation {
                self.player = player
            }
        } else {
            self.player = AVPlayer()
        }
    }
    
    @ViewBuilder private var content: some View {
        VStack(spacing: 8) {
            effectHeader
            videoPreview
        }
        .frame(width: 175)
    }
    
    private var effectHeader: some View {
        Text(effect.effect)
            .font(.appFont(.SubheadlineRegular))
            .foregroundStyle(.textMain)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
     private var videoPreview: some View {
         VideoPlayer(player: player)
             .disabled(true)
             .frame(width: 175, height: 220)
             .clipShape(.rect(cornerRadius: 8))
             .clipped()
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
    }
    
    private func setupPlayer() {
        if let urlStr = effect.previewSmall, let url = URL(string: urlStr) {
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.play()
            self.player = player
        } else {
            self.player = AVPlayer()
        }
    }
}

#Preview {
    EffectsV2EffectCard(
        effect: Effect(
            id: 1,
            ai: "pv",
            effect: "Popular",
            preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
            previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
        )
    )
    .padding()
    .background(Color.black)
    .environmentObject(EffectsV2Router())
    .environmentObject(Source())
}
