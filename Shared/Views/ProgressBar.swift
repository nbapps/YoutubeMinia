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
    
    var showValue = true
    var range: ClosedRange<Double> = 0...1
    var step: Double = 0.1
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(displayableTitle)
                
            Slider(value: $progress, in: range, step: step)
        }
    }
    
    var displayableTitle: String {
        showValue ? "\(title): \(progress.formatted(.percent.rounded(increment: 1)))" : title
    }
}

#Preview {
    ProgressBar(
        title: "Progress bar",
        progress: .constant(0.5)
    )
}
