import SwiftUI
import AVKit

struct UploadImageView: View {
    
    @EnvironmentObject var source: Source
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route.PreviewRoute.PhotoUploadRoute
    let effect: Effect
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    @State private var showingImagePicker = false
    @State var inputImage: UIImage?
    
    init(effect: Effect) {
        self.effect = effect
    }
    
    var body: some View {
        ZStack {
            Color.bgSecond.ignoresSafeArea()
            Color.bgMain.ignoresSafeArea()
                .padding(.top, safeAreaInsets.top)
            
            VStack(spacing: 0) {
                header
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        imageView
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .clipShape(.rect(cornerRadius: 8))
                    }
                    
                    Button {
                        if source.tokens < 1 {
                            print("SCOW PAYWALL SUBSCR \(source.proSubscription)")
                            if !source.proSubscription {
                                showPaywall = true
                                print("SCOW PAYWALL")
                            } else {
                                showPaywallToken = true
                            }
                        } else {
                            var effect = effect
                            effect.image = inputImage
                            router.path.append(nextScreen.generate(effect))
                        }
                    } label: {
                        Text("\(Image(systemName: "wand.and.stars")) Generate")
                            .font(.appFont(.Title2Emphasized))
                            .foregroundStyle(.textTertiary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: 64)
                            .background(Color.cSecondary)
                            .clipShape(.rect(cornerRadius: 8))
                    }
                    .disabled(inputImage == nil)
                    .opacity(inputImage == nil ? 0.3 : 1)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 27, trailing: 16))
            }
            

        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
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
        .toolbar(.hidden)
        .fullScreenCover(isPresented: $showPaywallToken) {
            TokensPaywall(show: $showPaywallToken)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(show: $showPaywall)
        }
    }
    
    private var header: some View {
        HStack(spacing: 6) {
            Button {
                router.path.removeLast()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")//make it button
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Back")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.white)
                }
            }
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
        .overlay(
            Text(effect.effect)
                .font(.appFont(.BodyEmphasized))
                .foregroundStyle(.white)
        )
    }
    
    @ViewBuilder var imageView: some View {
        if let inputImage = inputImage {
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - 99)
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    Button {
                        showingImagePicker = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.textMain)
                            Text("Replace image")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.textMain)
                        }
                        .frame(height: 60)
                    }
                )
                .frame(maxHeight: .infinity, alignment: .center)
        } else {
            VStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.textMain)
                    .frame(width: 32, height: 32)
                Text("Upload image")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.textMain)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgLight)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cSeparator, lineWidth: 1)
            )
            .onTapGesture {
                showingImagePicker = true
            }
        }
    }
}

#Preview {
    UploadImageView(effect:
                    Effect(
        id: 1,
        ai: "pv",
        effect: "Popular",
        preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
        previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
    ))
        .environmentObject(EffectsV2Router())
}
