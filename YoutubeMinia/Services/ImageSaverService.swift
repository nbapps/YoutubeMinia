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
    var onExportSuccess: (() -> Void)?
    
    func writeToPhotoAlbum(image: AppImage, videoURlStr: String, onExportSuccess: (() -> Void)?) {
        self.videoURlStr = videoURlStr
        self.onExportSuccess = onExportSuccess
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: AppImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        Task {
            do {
                try await notificationService.sendInstantNotification(
                    urlStr: videoURlStr ?? "",
                    message: String(localized: "!The thumbnail has been saved in your Photo library")
                )
                onExportSuccess?()
                videoURlStr = nil
            } catch {
                videoURlStr = nil
            }
        }
    }
}
#endif
