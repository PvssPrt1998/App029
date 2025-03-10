import SwiftUI

struct CategoryListView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreens = EffectsV2Route.CategoryListRoute
    let category: Category
    
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(category.items, id: \.self) { effect in
                        CategoryListCard(effect: effect)
                            .frame(height: 250)
                    }
                }
                .padding(16)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(category.header)
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
    }
}

#Preview {
    CategoryListView(
        category: Category(
            header: "CategoryName",
            items: [
                Effect(
                    id: 1,
                    ai: "pv",
                    effect: "Popular",
                    preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
                    previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
                )
            ]
        )
    )
    .padding()
    .background(Color.black)
    .environmentObject(EffectsV2Router())
}
