import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    @Binding var selection: Int
    @State var showPaywall = false
    
    @State var array: Array<Video>
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Your videos")
                        .font(.appFont(.Title2Emphasized))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        showPaywall = true
                    } label: {
                        Image("ProButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 82, height: 32)
                    }
                    .disabled(source.proSubscription)
                    .opacity(source.proSubscription ? 0 : 1)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                if array.isEmpty {
                    empty
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(array, id: \.self) { video in
                                HistoryListCard(video: video)
                                    .frame(height: 250)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .onReceive(source.categoriesArrayChangedPublisher) { output in
            array = source.historyArray
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Your videos")
                    .font(.appFont(.Title2Emphasized))
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image("ProButton")//make it button
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 32)
            }
        }
        .toolbarBackground(.bgSecond, for: .navigationBar)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
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
