//
//  FilePickerHelper.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 22.11.2024.
//

import Foundation
import UIKit
import UniformTypeIdentifiers


enum FilePickerHelper {
    
    private static let delegate = FilePickerDelegate()
    
    static func importFiles(types: [UTType], allowsMultipleSelection: Bool, on viewController: UIViewController?, completion: (([URL]) -> Void)?) {
        delegate.pickingDocumentHandler = nil
        guard let viewController else { return }
        
        delegate.pickingDocumentHandler = completion
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: types)
        controller.allowsMultipleSelection = allowsMultipleSelection
        controller.delegate = delegate
        viewController.present(controller, animated: true)
    }
    
    static func exportFiles(urls: [URL], asCopy: Bool, on viewController: UIViewController?, completion: (([URL]) -> Void)?) {
        delegate.pickingDocumentHandler = nil
        guard let viewController else { return }
        
        delegate.pickingDocumentHandler = completion
        let controller = UIDocumentPickerViewController(forExporting: urls, asCopy: asCopy)
        controller.delegate = delegate
        viewController.present(controller, animated: true)
    }
}

private class FilePickerDelegate: NSObject, UIDocumentPickerDelegate {
    var pickingDocumentHandler: (([URL]) -> Void)?
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.pickingDocumentHandler?([url])
            self?.pickingDocumentHandler = nil
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        DispatchQueue.main.async { [weak self] in
            self?.pickingDocumentHandler?(urls)
            self?.pickingDocumentHandler = nil
        }
    }
}
