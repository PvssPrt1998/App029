import SwiftUI

struct HistoryView: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    @Binding var selection: Int
    @State var showPaywall = false
    
    var body: some View {
        ZStack {
            Color.bgSecond.ignoresSafeArea()
            Color.bgMain.ignoresSafeArea()
                .padding(.top, safeAreaInsets.top)
            VStack(spacing: 16) {
                header
                if source.historyArray.isEmpty {
                    empty
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 8) {
                            ForEach(source.historyArray, id: \.self) { video in
                                HistoryListCard(video: video)
                                    .clipShape(.rect(cornerRadius: 8))
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .toolbar(.hidden)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
    
    private var header: some View {
        HStack(spacing: 6) {
            Text("Your videos")
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
    
    private var empty: some View {
        VStack(spacing: 8) {
            Text("You don't have a video yet.\nGenerate a video right now!")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Button {
                selection = 0
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.textTertiary)
                    Text("Generate")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.textTertiary)
                }
                .frame(width: 163, height: 48)
                .background(Color.cSecondary)
                .clipShape(.rect(cornerRadius: 8))
            }
        }
        .frame(maxHeight: .infinity)
    }
}
//
//#Preview {
//    HistoryView(
//        category: Category(
//            header: "CategoryName",
//            items: [
//                Effect(
//                    id: 1,
//                    ai: "pv",
//                    effect: "Popular",
//                    preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
//                    previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
//                )
//            ]
//        )
//    )
//    .padding()
//    .background(Color.black)
//    .environmentObject(EffectsV2Router())
//}
