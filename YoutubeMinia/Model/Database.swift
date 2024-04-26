//
//  Database.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftData
import SwiftUI

public extension View {
    func dataContainer(inMemory: Bool = false) -> some View {
        modifier(YMDataContainerViewModifier(inMemory: inMemory))
    }
    
    func generateMoc() -> some View {
        modifier(YMDataMocViewModifier())
    }
}

struct YMDataContainerViewModifier: ViewModifier {
    let container: ModelContainer
    
    init(inMemory: Bool) {
        Database.inMemory = inMemory
        container = Database.container
    }
    
    func body(content: Content) -> some View {
        content
            .modelContainer(container)
    }
}

struct YMDataMocViewModifier: ViewModifier {
    init() {
        Task {
            await Database.generateMoc()
        }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

actor Database {
    private init() {}
    
    static var inMemory = false
    
    static let container = {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    static let schema = SwiftData.Schema([
        PreviousURL.self
    ])
    
    @MainActor
    static func generateMoc() {
        guard inMemory else { return }
        container.mainContext.insert(
            try! PreviousURL.getMocItem()
        )
        container.mainContext.insert(
            try! PreviousURL.add(
                "https://www.youtube.com/watch?v=-Mvv9P5mDe4&pp=ygUNYmVuamFtaW4gY29kZQ%3D%3D",
                videoId: "Mvv9P5mDe4",
                title: "Perdre les clients de son Saas",
                thumbnailUrlStr: "https://i.ytimg.com/vi/f7_CHu0ADhM/default.jpg",
                timestamp: Date(timeIntervalSinceNow: -1000)
            )
        )
        container.mainContext.insert(
            try! PreviousURL.add(
                "https://www.youtube.com/watch?v=h2cVqKLcf2A&pp=ygUNYmVuamFtaW4gY29kZQ%3D%3D",
                videoId: "h2cVqKLcf2A",
                title: "La stack ultime pour créer un SaaS en 2024",
                thumbnailUrlStr: "https://i.ytimg.com/vi/f7_CHu0ADhM/default.jpg",
                timestamp: Date(timeIntervalSinceNow: -2000)
            )
        )
        container.mainContext.insert(
            try! PreviousURL.add(
                "https://www.youtube.com/watch?v=VKQB4asVRw4&pp=ygUNYmVuamFtaW4gY29kZQ%3D%3D",
                videoId: "VKQB4asVRw4",
                title: "La meilleure structure légale pour votre projet en 2024",
                thumbnailUrlStr: "https://i.ytimg.com/vi/f7_CHu0ADhM/default.jpg",
                timestamp: Date(timeIntervalSinceNow: -3000)
            )
        )
        container.mainContext.insert(
            try! PreviousURL.add(
                "https://www.youtube.com/watch?v=VKQB2asVRw4&pp=ygUNYmVuamFtaW4gY29kZQ%3D%3D",
                videoId: "VKQB4asVRw3",
                title: "test",
                thumbnailUrlStr: "https://i.ytimg.com/vi/f7_CHu0ADhM/default.jpg",
                timestamp: Date(timeIntervalSinceNow: -90000)
            )
        )
        
        try? container.mainContext.save()
    }
}
