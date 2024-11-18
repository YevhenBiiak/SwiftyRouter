//
//  ActivityItem.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 18.11.2024.
//

import Foundation
import LinkPresentation


final class ActivityItem: NSObject, UIActivityItemSource {
    
    private let title: String?
    private let subtitle: String?
    private let image: UIImage?
    private let item: Any
    
    init(item: Any, title: String? = nil, subtitle: String? = nil, image: UIImage? = nil) {
        self.item = item
        self.title = title
        self.subtitle = subtitle
        self.image = image
        super.init()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return item
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return item
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        if let image {
            metadata.iconProvider = NSItemProvider(object: image)
        }
        if let subtitle {
            metadata.originalURL = URL(fileURLWithPath: subtitle)
        }
        return metadata
    }
}
