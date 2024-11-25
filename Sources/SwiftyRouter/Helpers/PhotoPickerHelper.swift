//
//  PhotoPickerHelper.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 25.11.2024.
//

import Foundation
import PhotosUI


enum PhotoPickerHelper {
    
    private static let delegate = PhotoPickerDelegate()
    
    static func pickPhotos(on viewController: UIViewController?, filter: PHPickerFilter, limit: Int, _ completion: @escaping ([UIImage]) -> Void) {
        delegate.pickingPhotoHandler = nil
        guard let viewController else { return }
        
        delegate.pickingPhotoHandler = completion
        var config = PHPickerConfiguration()
        config.filter = filter
        config.selectionLimit = limit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = delegate
        viewController.present(picker, animated: true)
    }
    
    static func takePhoto(on viewController: UIViewController?, completion: @escaping (UIImage) -> Void) {
        delegate.takePhotoHandler = nil
        guard let viewController else { return }
        
        delegate.takePhotoHandler = completion
        let picker = UIImagePickerController()
        picker.delegate = delegate
        picker.sourceType = .camera
        viewController.present(picker, animated: true)
    }
}


private class PhotoPickerDelegate: NSObject {
    var pickingPhotoHandler: (([UIImage]) -> Void)?
    var takePhotoHandler: ((UIImage) -> Void)?
}

extension PhotoPickerDelegate: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
            picker.dismiss(animated: true) { [weak self] in
                self?.pickingPhotoHandler = nil
            }
            return
        }
        var images = [UIImage]()
        results.enumerated().forEach { index, result in
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error { print(error) }
                    if let image = image as? UIImage {
                        images.append(image)
                    }
                    
                    if index == results.count - 1 {
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true) { [weak self] in
                                self?.pickingPhotoHandler?(images)
                                self?.pickingPhotoHandler = nil
                            }
                        }
                    }
                }
            }
        }
    }
}

extension PhotoPickerDelegate: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        takePhotoHandler = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            if let image = info[.originalImage] as? UIImage {
                self?.takePhotoHandler?(image)
            }
            self?.takePhotoHandler = nil
        }
    }
}
