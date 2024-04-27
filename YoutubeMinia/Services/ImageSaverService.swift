//
//  ImageSaverService.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

#if os(iOS)
import SwiftUI

class ImageSaverService: NSObject {
    private let notificationService = NotificationService()
    
    private var videoURlStr: String?
    
    func writeToPhotoAlbum(image: AppImage, videoURlStr: String) {
        self.videoURlStr = videoURlStr
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: AppImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        Task {
            do {
                try await notificationService.sendInstantNotification(
                    urlStr: videoURlStr ?? "",
                    message: String(localized: "!The thumbnail has been saved in your Photo library")
                )
                videoURlStr = nil
            } catch {
                videoURlStr = nil
            }
        }
    }
}
#endif
