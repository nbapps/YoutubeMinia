//
//  ContentView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftUI
import SwiftData
import Combine
import FoundationKit

struct YMThumbnailData {
    let videoThumbnail: Image
    let channelThumbnail: Image
    let videoTitle: String
    let channelTitle: String
    let viewCount: String
    let channelCount: String
    let videoDuration: String
    let publicationDate: Date
}

extension YMThumbnailData {
    static let moc: Self =
        YMThumbnailData(
            videoThumbnail: Image("videoThumbnail"),
            channelThumbnail: Image("channelThumbail"),
            videoTitle: "Quel abonné codera la meilleure solution ?",
            channelTitle: "Benjamin Code",
            viewCount: "18k",
            channelCount: "131k",
            videoDuration: "16:31",
            publicationDate: Date(timeIntervalSince1970: 1643897325)
        )
    
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @StateObject private var viewModel = YMViewModel()

    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    TextField("https://www.youtube.com/watch?v=f7_CHu0ADhM", text: $viewModel.lastVideoURlStr)
                        .onSubmit(fetch)
                } header: {
                    Text("Video URL")
                }
                
                Section {
                    Toggle("Show duration", isOn: $viewModel.showDuration.animation())
                    Toggle("Show channel icon", isOn: $viewModel.showChannelIcon.animation())
                    Toggle("Show channel name", isOn: $viewModel.showChannelName.animation())
                    Toggle("Show view count", isOn: $viewModel.showViewCount.animation())
                    Toggle("Show publishing date", isOn: $viewModel.showPublishDate.animation())
                    Toggle("Show progress bar", isOn: $viewModel.showProgress.animation())

                    ProgressBar(title: "Progress bar", progress: $viewModel.lastProgress.animation())
                        .onChange(of: viewModel.lastProgress) { _, newValue in
                            viewModel.showProgress = newValue != 0
                        }
                    
                    Toggle("Dark theme", isOn: $viewModel.isDarkTheme.animation())
                    
                    ProgressBar(title: "Corner radius", progress: $viewModel.thumbnailCornerRadius)
                    
                        Button("fetch") {
                            fetch()
                        }
                } header: {
                    Text("Options")
                }
                .toggleStyle(.switch)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 300)
        } detail: {
            DetailView(viewModel: viewModel)
        }
    }
    // let url = URLComponents(string: lastVideoURlStr)
    func extractVideoId(from urlStr: String) -> String? {
        guard let comp = URLComponents(string: urlStr) else { return nil }
        return comp.queryItems?.first(where: { $0.name == "v"})?.value
    }
    
    func fetch() {
        do {
            Config.videoURL(for: "f7_CHu0ADhM")
            Config.channelURL(for: "UCLOAPb7ATQUs_nDs9ViLcMw")
            let videoData = try Bundle.main.loadJSONData(from: "devVideo.json")
            let videoDecoded = try JSONDecoder().decode(YTDecodable.self, from: videoData)
            viewModel.ytVideoInfos = videoDecoded
//            print("https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(videoDecoded.items.first!.snippet.channelId)&key=\(viewModel.apiKey)")
            
            let channelData = try Bundle.main.loadJSONData(from: "devChannel.json")
            let channelDecoded = try JSONDecoder().decode(YTDecodable.self, from: channelData)
            viewModel.ytChannelInfos = channelDecoded
//            print(channelDecoded)
        } catch {
            print(error)
        }
    }
}

extension View {
    func thumbnailShadow(radius: CGFloat = 4) -> some View {
        self
        .shadow(color: .clear, radius: radius)
        .shadow(color: .black.opacity(0.2), radius: radius)
    }
}
struct DetailView: View {
    @ObservedObject var viewModel: YMViewModel
    
    let width: CGFloat = 330
    var body: some View {
        VStack {
            if let thumbnailData = viewModel.ymThumbnailData {
                makeThumbnail(thumbnailData)
            }
        }
        .toolbar(content: {
                Button {
                    if let thumbnailData = viewModel.ymThumbnailData {
                        let renderer = ImageRenderer(content: makeThumbnail(thumbnailData))
                        if let img = renderer.nsImage {
                            let pb = NSPasteboard.general
                            pb.clearContents()
                            pb.writeObjects([img])
                            print("copied")
                        }
                    }
                } label: {
                    Image(systemName: "doc.on.doc")
                }
            
        })
    }
    
    @ViewBuilder
    func makeThumbnail(_ thumbnailData: YMThumbnailData) -> some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                thumbnailData.videoThumbnail
                    .resizable()
                    .scaledToFit()
                
                if viewModel.showDuration {
                    Text(thumbnailData.videoDuration)
                        .font(Font.custom("Roboto-Medium", size: 12))
                        .foregroundStyle( .white)
                        .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6))
                        .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
                        .padding(8)
                }
                
                if viewModel.showProgress {
                    ProgressView("", value: viewModel.lastProgress)
                        .offset(y: 5)
                        .tint(.red)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
            .thumbnailShadow(radius: 8)
            
            HStack(alignment: .top, spacing: 16) {
                if viewModel.showChannelIcon {
                    thumbnailData.channelThumbnail
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .clipShape(Circle())
                        .thumbnailShadow()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(thumbnailData.videoTitle)
                        .multilineTextAlignment(.leading)
                        .font(Font.custom("Roboto-Medium", size: 14))
                        .foregroundStyle(viewModel.isDarkTheme ? .white : .black)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if viewModel.showChannelName {
                            Text(thumbnailData.channelTitle)
                        }
                        HStack {
                            if viewModel.showViewCount {
                                Text(thumbnailData.viewCount)
                            }
                            
                            if viewModel.showPublishDate {
                                Text(thumbnailData.publicationDate, style: .relative)
                            }
                        }
                    }
                    .font(Font.custom("Roboto-Regular", size: 12))
                    .foregroundStyle(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: width)
        .padding(20)
        .background(viewModel.isDarkTheme ? .black.opacity(0.94) : .white, in: RoundedRectangle(cornerRadius: outerCornerRadius))
        .background(.white, in: RoundedRectangle(cornerRadius: outerCornerRadius))
        .shadow(color: .clear, radius: 10)
        .thumbnailShadow(radius: 8)
    }
    var innerCornerRadius: Double {
        width * viewModel.thumbnailCornerRadius * 0.1
    }
    var outerCornerRadius: Double {
        innerCornerRadius * 2
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 500)
        .dataContainer(inMemory: true)
}

extension ContentView {
//    Button("dd") {
//        
//        fetchVideoInfo(videoId: extractVideoId(from: "https://www.youtube.com/watch?v=f7_CHu0ADhM")!, apiKey: Config.getValue(for: .youtubeApiKey)!) { result in
//            switch result {
//            case .success(let thumbnailURL):
//                print("Thumbnail URL: \(thumbnailURL)")
//            case .failure(let error):
//                print("Error fetching video info: \(error)")
//            }
//        }
//    }
    
    func fetchVideoInfo(videoId: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=\(videoId)&key=\(apiKey)"
        let urlString11 = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(123)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(YTDecodable.self, from: data)
                print(decoded)
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                
                let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
                let prettyPrintedString = String(data: data!, encoding: .utf8)
                
//                print(prettyPrintedString!)
                
                if let items = json?["items"] as? [[String: Any]], let snippet = items.first?["snippet"] as? [String: Any], let thumbnails = snippet["thumbnails"] as? [String: Any], let defaultThumbnail = thumbnails["default"] as? [String: Any], let thumbnailURL = defaultThumbnail["url"] as? String {
                    completion(.success(thumbnailURL))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

final class NetworkService {
    var session = URLSession.shared
    
    func tt() async throws {
        let data: Data = try await fetch(url: URL(string: "https://yt3.ggpht.com/ytc/AIdro_ladyg5fV6ymBjPWBVtxYT06g8wSVa4-wnvez7kd9T-Ums=s88-c-k-c0x00ffffff-no-rj")!)
//        Image(nsImage: NSImage(data: data))
    }
    
    func fetch<T: Decodable>(url: URL) async throws -> T {
        let data: Data = try await fetch(url: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetch(url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
