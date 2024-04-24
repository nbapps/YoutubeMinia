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
        Item.self,
    ])
    
    @MainActor
    static func generateMoc() {
        guard inMemory else { return }

    }
}
