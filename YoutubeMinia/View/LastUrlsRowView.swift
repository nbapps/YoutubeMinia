//
//  LastUrlsRowView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import SwiftUI

struct LastUrlsRowView: View {
    let previousURL: PreviousURL
    
    let networkService = NetworkService()
    
    @State private var image: Image?
    
    var body: some View {
        Section {
            HStack(alignment: .top, spacing: 16) {
                makeThumbnail()
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: previousURL.title)
                        .lineLimit(2)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Text(previousURL.urlStr)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                }
            }
        } footer: {
            Text(previousURL.timestamp, style: .offset)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .task {
            do {
                let data = try await networkService.fetch(url: previousURL.thumbnailUrl)
                guard let appImage = AppImage(data: data) else { return }
                image = Image(appImage: appImage)
            } catch {
                print(error)
            }
        }
    }
    
    @ViewBuilder
    func makeThumbnail() -> some View {
        if let image {
            image
                .resizable()
                .scaledToFit()
        } else {
            ProgressView()
        }
    }
}

#Preview {
    List {
        LastUrlsRowView(
            previousURL: try! PreviousURL.getMocItem()
        )
    }
    .dataContainer(inMemory: true)
    .generateMoc()
}
