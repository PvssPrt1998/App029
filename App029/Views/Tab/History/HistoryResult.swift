import SwiftUI
import _AVKit_SwiftUI
import Photos

struct HistoryResult: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var source: Source
    @State var showActionSheetGenerated = false
    let video: Video
    @Binding var show: Bool
    @State var player = AVPlayer()
    
    @State var alertUploaded = false
    @State var alertNotUploaded = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    show = false
                } label: {
                    Text("Close")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.textMain)
                }
                Spacer()
                Button {
                    showActionSheetGenerated = true
                } label: {
                    Image(systemName: "ellipsis")//make it button
                        .font(.system(size: 17, weight: .regular))
                        .frame(width: 40, height: 32)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            
            VideoPlayer(player: player)
                .disabled(true)
                .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - 87)
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
        .frame(maxHeight: .infinity)
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
        .confirmationDialog("", isPresented: $showActionSheetGenerated, titleVisibility: .hidden) {
                        Button("Download") {
                            downloadVideo()
                        }

                        Button("Share") {
                            share()
                        }

                        Button("Delete", role: .destructive) {
                            delete()
                            show = false
                        }
                    }
    }
    
    private func delete() {
        source.removeVideo(id: video.id)
    }
    
    private func share() {
        guard let urlStr = video.url,let urlShare = URL(string: urlStr)  else { return }
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
        // Убедимся, что URL корректный
        guard let videoUrlString = video.url, let videoUrl = URL(string: videoUrlString) else {
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
    
    
}
