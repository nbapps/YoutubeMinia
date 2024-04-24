//
//  ProgressBar.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftUI

struct ProgressBar: View {
    let title: String
    
    @Binding var progress: Double
    var range: ClosedRange<Double> = 0...1
    let step: Double = 0.1
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title): \(progress.formatted(.percent.rounded(increment: 1)))")
                .padding(.leading, 8)
            Slider(value: $progress, in: range, step: step)
        }
    }
}

#Preview {
    ProgressBar(
        title: "Progress bar",
        progress: .constant(0.5)
    )
}
