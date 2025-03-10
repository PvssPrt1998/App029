import SwiftUI
import Photos
import AVKit

struct GenerationView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @State var alertUploaded = false
    @State var alertNotUploaded = false
    
    @State var showActionSheetGenerating = false
    @State var showActionSheetGenerated = false
    
    @ObservedObject var generationViewHelper = GenerationViewHelper()
    @State var generating = true
    @State var player = AVPlayer()
    let effect: Effect
    
    @State var videoGenerationErrorAlertShow = false
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            if generating {
                generatingView
            } else {
                resultView
            }
        }
        .onAppear {
            if !generationViewHelper.onAppearCalled {
                generationViewHelper.onAppearCalled = true
                send()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(generating ? "Generation" : "Result")
                    .font(.appFont(.BodyEmphasized))
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if generating {
                        showActionSheetGenerating = true
                    } else {
                        showActionSheetGenerated = true
                    }
                } label: {
                    Image(systemName: "ellipsis")//make it button
                        .font(.system(size: 17, weight: .regular))
                        .frame(width: 40, height: 32)
                }
                .disabled(source.generationIdForDelete == nil)
                .opacity(source.generationIdForDelete == nil ? 0.3 : 1)
            }
        }
        .toolbarBackground(.bgSecond, for: .navigationBar)
        .alert("Video generation error", isPresented: $videoGenerationErrorAlertShow) {
            Button("Cancel", role: .cancel) {
//                while router.path.count > 0 {
//                    router.path.removeLast()
//                }
                videoGenerationErrorAlertShow = false
                router.path = NavigationPath()
            }
            Button("Try again", role: .none) {
                videoGenerationErrorAlertShow = false
                send()
            }
        } message: {
            Text("Something went wrong or the server is not responding. Try again or do it later.")
        }
        .alert("Success", isPresented: $alertUploaded) {
            Button("OK", role: .cancel) {alertUploaded = false}
        } message: {
            Text("Video uploaded to gallery")
        }
        .alert("Error", isPresented: $alertNotUploaded) {
            Button("OK", role: .cancel) {alertNotUploaded = false}
            Button("Try again", role: .none) {
                self.downloadVideo()
                alertNotUploaded = false
            }
        } message: {
            Text("Video upload error")
        }
        .confirmationDialog("", isPresented: $showActionSheetGenerating, titleVisibility: .hidden) {
                        Button("Download") {
                        }
                        .disabled(true)

                        Button("Share") {
                            
                        }
                        .disabled(true)

                        Button("Delete", role: .destructive) {
                            guard let id = source.generationIdForDelete else { return }
                            source.removeVideo(id: id)
                        }
                    }
        .confirmationDialog("", isPresented: $showActionSheetGenerated, titleVisibility: .hidden) {
                        Button("Download") {
                            downloadVideo()
                        }

                        Button("Share") {
                            share()
                        }

                        Button("Delete", role: .destructive) {
                            guard let id = source.generationIdForDelete else { return }
                            source.removeVideo(id: id)
                            router.path = NavigationPath()
                        }
                    }
    }
    
    func send() {
        guard let imageBlur = effect.image, let imageData = imageBlur.jpegData(compressionQuality: 0.5) else {
            showErrorAlert()
            return
        }
        source.createVideo(image: imageData, effectID: effect.id, effectName: effect.effect) { generationID in
            self.source.generationIdForDelete = generationID
            print("CreateVideo.generation id: " + generationID)
            self.checkVideoStatus(generationID) { status, url in
                print("ALL DONE GENERATION " + status + " " + url)
                source.genIDArr.remove(generationID)
                source.saveCompletedVideo(generationID, status: status, url: url)
                self.prepareForShowVideo(urlStr: url)
            } errorHandler: {
                showErrorAlert()
            }
        } errorHandler: {
            showErrorAlert()
        }
    }
    
    private func share() {
        guard let id = source.generationIdForDelete, let index = source.historyArray.firstIndex(where: {$0.id == id}) else { return }
        guard let urlStr = source.historyArray[index].url ,let urlShare = URL(string: urlStr)  else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        if #available(iOS 15.0, *) {
            UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController?
            .present(activityVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func downloadVideo() {
        guard let id = source.generationIdForDelete, let index = source.historyArray.firstIndex(where: {$0.id == id}) else { return }
        // Убедимся, что URL корректный
        guard let videoUrlString = source.historyArray[index].url, let videoUrl = URL(string: videoUrlString) else {
            print("Invalid video URL")
            return
        }
        
        // Скачиваем видео во временную директорию
        let tempFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedVideo.mp4")
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: videoUrl) { location, response, error in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                return
            }
            
            guard let location = location else {
                print("No file location")
                return
            }
            
            do {
                // Удаляем старый файл, если он существует
                if FileManager.default.fileExists(atPath: tempFilePath.path) {
                    try FileManager.default.removeItem(at: tempFilePath)
                }
                
                // Перемещаем загруженный файл во временную директорию с расширением .mp4
                try FileManager.default.moveItem(at: location, to: tempFilePath)
                
                // Сохраняем видео в галерею
                self.saveVideoToGallery(tempFilePath)
            } catch {
                print("Error handling file: \(error.localizedDescription)")
            }
        }
        
        downloadTask.resume()
    }

    private func saveVideoToGallery(_ fileUrl: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: fileUrl, options: nil)
        }) { success, error in
            // Используем self, чтобы предотвратить утечку памяти
            DispatchQueue.main.async {
                if success {
                    alertUploaded = true
                    print("Video saved to gallery successfully")
                } else if let error = error {
                    alertNotUploaded = true
                    print("Error saving video: \(error.localizedDescription)")
                } else {
                    alertNotUploaded = true
                    print("Unknown error occurred while saving video")
                }
            }
        }
    }
    
    func checkVideoStatus(_ generationID: String, completion: @escaping (String, String) -> Void, errorHandler: @escaping () -> Void) {
        self.source.genIDArr.insert(generationID)
        self.source.videoStatus(generationID: generationID) { status, url in
            let uiImage = effect.image ?? UIImage()
            let uiImageData = uiImage.pngData() ?? Data()
            self.source.savePendingVideo(generationID, status: status, effect: self.effect.effect, image: uiImageData)
            print(status)
            if status == "finished" {
                completion(status, url)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    checkVideoStatus(generationID) { status, url in
                        completion(status, url)
                    } errorHandler: {
                        errorHandler()
                    }
                }
            }
        } errorHandler: {
            errorHandler()
        }
    }
    
    func prepareForShowVideo(urlStr: String) {
        if let url = URL(string: urlStr) {
            print("GENERATED VIDEO URL" + urlStr)
            let player = AVPlayer(url: url)
            player.play()
            self.player = player
            self.generating = false
            //VIDEO_SAVE
        } else {
            //change status video to error VIDEO_ERROR
            showErrorAlert()
        }
    }
    
    func showErrorAlert() {
        videoGenerationErrorAlertShow = true
    }
    
    private var resultView: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - 43)
            .clipShape(.rect(cornerRadius: 8))
            .clipped()
            .onAppear { player.play() }
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
            .padding(.top, 16)
    }
    
    private var generatingView: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.cSeparator, lineWidth: 1)
            .background(LinearGradient(colors: [.lg1, .lg2], startPoint: .top, endPoint: .bottom))
            .overlay(
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.labelsSecondary)
                        Text("Generation")
                            .font(.appFont(.BodyRegular))
                            .foregroundStyle(Color.labelsSecondary)
                    }
                    Text("~45 seconds left")
                        .font(.appFont(.BodyRegular))
                        .foregroundStyle(Color.textMain)
                }
            )
            .clipShape(.rect(cornerRadius: 8))
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 27, trailing: 16))
    }
}

#Preview {
    GenerationView(
        effect: Effect(
            id: 1,
            ai: "pv",
            effect: "Popular",
            preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
            previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
            )
    )
        .environmentObject(Source())
        .environmentObject(EffectsV2Router())
}

class GenerationViewHelper: ObservableObject {
    
    var onAppearCalled = false
    var idGen: String = ""
}
