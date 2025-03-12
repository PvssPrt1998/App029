import SwiftUI
import AVKit

struct HistoryListCard: View {
    
    @ObservedObject var doubleLoadHelper = DoubleLoadHelper()
    let documentManager = DocumentManager()
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    
    @State var showSheet = false
    
    enum GenerationState {
        case pending
        case completed
        case error
    }
    
    @State var generationState: GenerationState
    
    @State var player: AVPlayer
    @State var video: Video
    
    init(video: Video) {
        self.video = video
        if video.status == "finished" {
            generationState = .completed
        } else if video.status == "error" {
            generationState = .error
        } else {
            generationState = .pending
        }
        player = AVPlayer()
    }
    
    func load() {
        if video.status != "error"{
            if video.status != "finished" {
                if !source.genIDArr.contains(video.id) {
                    self.checkVideoStatus(video.id) { status, url in
                        self.generationState = .completed
                        if let index = source.historyArray.firstIndex(where: {$0.id == video.id}) {
                            source.historyArray[index].status = status
                            source.historyArray[index].url = url
                        }
                        
                    } errorHandler: {
                        self.generationState = .error
                    }
                }
            } else {
                if let localUrlStr = fetchVideoFromDocuments(filename: video.id + ".mp4"), let url = URL(string: localUrlStr), let urlData = NSData(contentsOf: url)  {
                    //print("Load local")
                    let player = AVPlayer(url: url)
                    player.isMuted = true
                    player.play()
                    self.player = player
                } else if let urlStr = video.url, let url = URL(string: urlStr) {
                    reloadInDocuments()
                    let player = AVPlayer(url: url)
                    player.isMuted = true
                    player.play()
                    self.player = player
                } else {
                    self.player = AVPlayer()
                }
            }
        }
    }
    
    func reloadInDocuments() {
        print("Handle unable local load")
        self.documentManager.removeVideoBy(filename: video.id + ".mp4")//Remove old From DOC
        guard let urlStr = video.url else { return }
        self.documentManager.downloadVideoGenerated(urlStr: urlStr, id: video.id) { str in
            print("SAVED TO LOCAL URL History: " + str)
        }
    }
    
    var body: some View {
        bodyContent
            .onAppear {
                if !doubleLoadHelper.loaded {
                    doubleLoadHelper.loaded = true
                    load()
                }
                player.play()
            }
            .onDisappear {
                player.pause()
            }
    }
    
    @ViewBuilder var bodyContent: some View {
        switch generationState {
        case .completed: content
        case .pending: pendingContent
        case .error: errorComponent
        }
    }
    
    func checkVideoStatus(_ generationID: String, completion: @escaping (String, String) -> Void, errorHandler: @escaping () -> Void) {
        self.source.videoStatus(generationID: generationID) { status, url in
            print(status)
            if status == "finished" {
                source.genIDArr.remove(generationID)
                video.status = status
                video.url = url
                print("From history card")
                source.saveCompletedVideo(generationID, status: status, url: url)
                completion(status, url)
            } else if status != "error" {
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
    
    private var pendingContent: some View {
        ZStack {
            if let image = imageFromData {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: (UIScreen.main.bounds.width - 40)/2, height: (UIScreen.main.bounds.width - 40)/2)
                    .clipped()
                LinearGradient(colors: [.black.opacity(0.7), .black.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 25)
                    .frame(maxHeight: .infinity, alignment: .top)
            } else {
                Rectangle()
                    .fill(.white.opacity(0.3))
            }
            
            Text("Video still generating")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.textMain)
        }
        .frame(width: (UIScreen.main.bounds.width - 40)/2, height: (UIScreen.main.bounds.width - 40)/2)
        .clipShape(.rect(cornerRadius: 8))
    }
    
    private var errorComponent: some View {
        Rectangle()
            .fill(.white.opacity(0.3))
            .overlay(
                VStack(spacing: 6) {
                    Text("Generation error")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.textMain)
                    Button {
                        source.removeVideo(id: video.id)
                    } label: {
                        Text("Delete")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.red)
                            .frame(width: 70, height: 30)
                    }
                }
            )
            .frame(width: (UIScreen.main.bounds.width - 40)/2, height: (UIScreen.main.bounds.width - 40)/2)
            .clipShape(.rect(cornerRadius: 8))
    }
    
    private var imageFromData: Image? {
        if let uiImage = UIImage(data: video.image) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    private var content: some View {
        Button {
            //showSheet = true
            if video.status == "finished" {
                router.path.append(EffectsV2Route.historyResult(video))
            }
        } label: {
            ZStack {
                videoPreview
                    .clipShape(.rect(cornerRadius: 8))
                effectHeader
                LinearGradient(colors: [.black.opacity(0.7), .black.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 25)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(width: (UIScreen.main.bounds.width - 40)/2, height: (UIScreen.main.bounds.width - 40)/2)
            .clipShape(.rect(cornerRadius: 8))
        }
    }
    
    private var effectHeader: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.textMain)
            Text(video.effect)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.textMain)
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
     private var videoPreview: some View {
         VideoPlayer(player: player)
             .disabled(true)
             .frame(width: ((UIScreen.main.bounds.width - 40)/2) * 16 / 9, height: 175 * 16 / 9)
             .frame(width: (UIScreen.main.bounds.width - 40)/2, height: (UIScreen.main.bounds.width - 40)/2)
             .clipShape(.rect(cornerRadius: 8))
             .clipped()
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
    }
    
    func fetchVideoFromDocuments(filename: String) -> String? {
        //guard let url: NSURL = NSURL(string: urlStr), let filename = url.lastPathComponent else { return nil }
        let newPath = "file:///" + documentsPathForFileName(name: "/" + filename)
        return newPath
    }
    
    func documentsPathForFileName(name: String) -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return documentsPath.appending(name)
    }
}

//#Preview {
//    HistoryListCard(
//        effect: Effect(
//            id: 1,
//            ai: "pv",
//            effect: "Popular",
//            preview: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790",
//            previewSmall: "https://vewapnew.online/storage/preview/aw7412CfGnx2YgtYWaWERbgcUQA3DLsTFRpGZYgW.mp4?t=1741170790"
//        )
//    )
//    .padding()
//    .background(Color.black)
//    .environmentObject(EffectsV2Router())
//}

final class DoubleLoadHelper: ObservableObject {
    var loaded = false
    
}
