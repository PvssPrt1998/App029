import SwiftUI

struct Tab: View {
    
    @EnvironmentObject var router: EffectsV2Router
    @EnvironmentObject var source: Source
    @State var selection = 0
    @State var showPaywall = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.stackedLayoutAppearance.normal.iconColor = .textNotActive
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.textNotActive]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(rgbColorCodeRed: 255, green: 240, blue: 208, alpha: 1)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.cSecondary]
        appearance.backgroundColor = UIColor.bgSecond
        appearance.shadowColor = .white.withAlphaComponent(0.15)
        appearance.shadowImage = UIImage(named: "tab-shadow")?.withRenderingMode(.alwaysTemplate)
        UITabBar.appearance().backgroundColor = UIColor.bgSecond
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            tab
                .navigationDestination(for: EffectsV2Route.self) { route in
                    switch route {
                    case .categoryList(let category): CategoryListView(category: category).environmentObject(router)
                    case .preview(let effect): PreviewView(effect: effect).environmentObject(router)
                    case .historyResult(let video): HistoryResult(video: video)
                    }
                }
                .navigationDestination(for: EffectsV2Route.PreviewRoute.self) { route in
                    switch route {
                    case .photoUpload(let effect): UploadImageView(effect: effect)
                    case .photoUploadDouble(let effect): UploadImageViewDouble(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.PreviewRoute.PhotoUploadRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.PreviewRoute.PhotoUploadDoubleRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.self) { route in
                    switch route {
                    case .preview(let effect): PreviewView(effect: effect).environmentObject(router)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.PreviewRoute.self) { route in
                    switch route {
                    case .photoUpload(let effect): UploadImageView(effect: effect)
                    case .photoUploadDouble(let effect): UploadImageViewDouble(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.PreviewRoute.PhotoUploadRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
                .navigationDestination(for: EffectsV2Route.CategoryListRoute.PreviewRoute.PhotoUploadDoubleRoute.self) { route in
                    switch route {
                    case .generate(let effect): GenerationView(effect: effect)
                    }
                }
                .fullScreenCover(isPresented: $showPaywall) {
                    PaywallView(show: $showPaywall)
                }
                .toolbar(.hidden)
        }
        
    }
    
    private var tab: some View {
        TabView(selection: $selection) {
            EffectsV2View()
                .tabItem { VStack {
                    tabViewImage("bolt.fill")
                    Text("Effects").font(.system(size: 10, weight: .medium))
                } }
                .tag(0)
            HistoryView(selection: $selection)
                .tabItem { VStack {
                    tabViewImage("video.circle.fill")
                    Text("My Videos").font(.system(size: 10, weight: .medium))
                } }
                .tag(1)
            SettingsView()
                .tabItem {
                    VStack {
                        tabViewImage("gearshape.fill")
                        Text("Settings") .font(.system(size: 10, weight: .medium))
                    }
                }
                .tag(2)
        }
    }
    
//    @ViewBuilder var generateView: some View {
//        switch tabScreen {
//        case .generationChoice:
//            GenerationChoice(screen: $tabScreen)
//        case .videoImageGenerator:
//            VideoImageGenerator(screen: $tabScreen)
//        case .videoResult:
//            GenerationResult(screen: $tabScreen)
//        case .promtResult:
//            PromtGenerationView(screen: $tabScreen)
//        }
//    }
    
    @ViewBuilder func tabViewImage(_ systemName: String) -> some View {
        if #available(iOS 15.0, *) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .environment(\.symbolVariants, .none)
        } else {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
        }
    }
}

struct Tab_Preview: PreviewProvider {

    static var previews: some View {
        Tab()
            .environmentObject(Source())
    }
}

extension UIColor {
   convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {

     let redPart: CGFloat = CGFloat(red) / 255
     let greenPart: CGFloat = CGFloat(green) / 255
     let bluePart: CGFloat = CGFloat(blue) / 255

     self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
   }
}

extension UITabBarController {
    var height: CGFloat {
        return self.tabBar.frame.size.height
    }
    
    var width: CGFloat {
        return self.tabBar.frame.size.width
    }
}
