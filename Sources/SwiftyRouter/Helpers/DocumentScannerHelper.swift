//
//  DocumentScannerHelper.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 25.11.2024.
//

import Foundation
import VisionKit


enum DocumentScannerHelper {
    
    private static let delegate = DocumentScannerDelegate()
    
    static func scanDocument(on viewController: UIViewController?, completion: (([DocumentScan]) -> Void)?) {
        delegate.scanDocumentsHandler = nil
        guard let viewController else { return }
        
        delegate.scanDocumentsHandler = completion
        let controller = VNDocumentCameraViewController()
        controller.delegate = delegate
        viewController.present(controller, animated: true)
    }
}

public struct DocumentScan {
    public let title: String
    public let image: UIImage
}

private class DocumentScannerDelegate: NSObject, VNDocumentCameraViewControllerDelegate {
    var scanDocumentsHandler: (([DocumentScan]) -> Void)?
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        scanDocumentsHandler = nil
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let docScans = (0..<scan.pageCount).map {
            let title = scan.title
            let image = scan.imageOfPage(at: $0)
            return DocumentScan(title: title, image: image)
        }
        scanDocumentsHandler?(docScans)
        scanDocumentsHandler = nil
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
        scanDocumentsHandler = nil
        controller.dismiss(animated: true)
    }
}
