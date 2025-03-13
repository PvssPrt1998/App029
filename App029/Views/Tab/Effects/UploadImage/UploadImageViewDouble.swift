import SwiftUI
import AVKit

struct UploadImageViewDouble: View {
    
    @EnvironmentObject var source: Source
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var router: EffectsV2Router
    typealias nextScreen = EffectsV2Route.PreviewRoute.PhotoUploadRoute
    let effect: Effect
    
    @State var showPaywallToken = false
    @State var showPaywall = false
    
    @State var imageMergeAlertShow = false
    
    @State private var showingImagePicker = false
    @State private var showingImagePicker1 = false
    @State var inputImage: UIImage?
    @State var inputImage1: UIImage?
    
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
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            imageView
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .clipShape(.rect(cornerRadius: 8))
                        }
                        GeometryReader { geometry in
                            imageView1
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                    Button {
                        guard source.tokens >= 1 else {
                            if !source.proSubscription {
                                showPaywall = true
                            } else {
                                showPaywallToken = true
                            }
                            return
                        }
                        if let image1 = inputImage, let image2 = inputImage1, let image = combineImagesWithBlur(image1, image2) {
                            var effect = effect
                            effect.image = image
                            router.path.append(nextScreen.generate(effect))
                        } else {
                            imageMergeAlertShow = true
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
                    .disabled(inputImage == nil || inputImage1 == nil)
                    .opacity(inputImage == nil || inputImage1 == nil ? 0.3 : 1)
                    .alert("Merge images error", isPresented: $imageMergeAlertShow) {
                        Button("OK", role: .cancel) {imageMergeAlertShow = false}
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 27, trailing: 16))
            }
            .frame(maxHeight: .infinity, alignment: .top)
            

        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showingImagePicker1) {
            ImagePicker(image: $inputImage1)
                .ignoresSafeArea()
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
    
    func combineImagesWithBlur(_ leftImage: UIImage, _ rightImage: UIImage) -> UIImage? {
        // Определяем максимальную высоту
        let maxHeight = max(leftImage.size.height, rightImage.size.height)
        
        // Масштабируем обе картинки, чтобы их высота совпадала с maxHeight
        let leftScale = maxHeight / leftImage.size.height
        let rightScale = maxHeight / rightImage.size.height
        
        let scaledLeftWidth = leftImage.size.width * leftScale
        let scaledRightWidth = rightImage.size.width * rightScale
        
        // Общая ширина
        let totalWidth = scaledLeftWidth + scaledRightWidth
        
        // Создаем контекст с нужными размерами
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: maxHeight), false, 0.0)
        
        // Масштабируем и рисуем левое изображение
        let leftRect = CGRect(x: 0, y: 0, width: scaledLeftWidth, height: maxHeight)
        leftImage.draw(in: leftRect)
        
        // Масштабируем и рисуем правое изображение
        let rightRect = CGRect(x: scaledLeftWidth, y: 0, width: scaledRightWidth, height: maxHeight)
        rightImage.draw(in: rightRect)
        
        // Создаем градиент на стыке изображений
        let gradientWidth: CGFloat = 20.0 // Ширина размытия
        let gradientStartX = scaledLeftWidth - gradientWidth / 2
        let gradientEndX = scaledLeftWidth + gradientWidth / 2
        
        if let context = UIGraphicsGetCurrentContext() {
            let colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor
            ]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
            
            let gradientRect = CGRect(x: gradientStartX, y: 0, width: gradientWidth, height: maxHeight)
            context.saveGState()
            context.clip(to: gradientRect)
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: gradientStartX, y: 0),
                end: CGPoint(x: gradientEndX, y: 0),
                options: []
            )
            context.restoreGState()
        }
        
        // Получаем результирующее изображение
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
    @ViewBuilder var imageView: some View {
        if let inputImage = inputImage {
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: (UIScreen.main.bounds.width - 40) / 14 * 12)
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
            .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: (UIScreen.main.bounds.width - 40) / 14 * 12)
            .background(Color.bgLight)
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cSeparator, lineWidth: 1)
            )
            .onTapGesture {
                showingImagePicker = true
            }
        }
    }
    
    @ViewBuilder private var imageView1: some View {
        if let inputImage1 = inputImage1 {
            Image(uiImage: inputImage1)
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: (UIScreen.main.bounds.width - 40) / 14 * 12)
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    Button {
                        showingImagePicker1 = true
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
            .frame(width: (UIScreen.main.bounds.width - 40) / 2 , height: (UIScreen.main.bounds.width - 40) / 14 * 12)
            .background(Color.bgLight)
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cSeparator, lineWidth: 1)
            )
            .onTapGesture {
                showingImagePicker1 = true
            }
        }
    }
}

#Preview {
    UploadImageViewDouble(effect:
                    Effect(
        id: 1,
        ai: "pv",
        effect: "Popular",
        preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
        previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
    ))
        .environmentObject(EffectsV2Router())
}
