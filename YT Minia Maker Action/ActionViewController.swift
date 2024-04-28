//
//  ActionViewController.swift
//  YT Minia Maker Action
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

final class ActionViewModel: ObservableObject {
    @Published var isValidYTURL = false
}

class ActionViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    private var actionViewModel = ActionViewModel()
    
    lazy var thumbnailMakerViewModel = ThumbnailMakerViewModel(fetchOnLaunch: false)
    
    lazy var actionHostingView: UIHostingController<some View> = {
        let actionView = ActionView(
            actionViewModel: self.actionViewModel,
            thumbnailMakerViewModel: self.thumbnailMakerViewModel,
            onClose: done
        )
        
        var v = UIHostingController(rootView: actionView)
        v.view.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        thumbnailMakerViewModel.onExportSuccess = { [weak self] in
            self?.done()
        }
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil, completionHandler: { [weak self] (item, error) in
                            if let unsafeUrl = item as? URL, let urlStr = self?.thumbnailMakerViewModel.checkIfURLIsValid(urlStr: unsafeUrl.absoluteString) {
                                self?.actionViewModel.isValidYTURL = true
                                self?.thumbnailMakerViewModel.videoURlStr = urlStr
                            }
                        })
                        break
                    }
                    
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil, completionHandler: { [weak self] (item, error) in
                            if let unsafeUrlStr = item as? String, let urlStr = self?.thumbnailMakerViewModel.checkIfURLIsValid(urlStr: unsafeUrlStr) {
                                self?.actionViewModel.isValidYTURL = true
                                self?.thumbnailMakerViewModel.videoURlStr = urlStr
                            }
                        })
                        break
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            container.addSubview(actionHostingView.view)
            
            NSLayoutConstraint.activate([
                actionHostingView.view.topAnchor.constraint(equalTo: container.topAnchor),
                actionHostingView.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                actionHostingView.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                actionHostingView.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
        
    }
    
    func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
