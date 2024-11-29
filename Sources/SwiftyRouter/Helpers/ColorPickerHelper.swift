//
//  ColorPickerHelper.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 22.11.2024.
//

import UIKit


enum ColorPickerHelper {
    
    private static let delegate = ColorPickerViewControllerDelegate()
    
    static func pick(on viewController: UIViewController?, title: String? = nil, completion: @escaping (UIColor) -> Void) {
        delegate.pickingColorHandler = nil
        guard let viewController else { return }
        
        delegate.pickingColorHandler = completion
        let controller = UIColorPickerViewController()
        if let title {
            controller.title = title
        }
        controller.delegate = delegate
        viewController.present(controller, animated: true)
    }
}

private class ColorPickerViewControllerDelegate: NSObject, UIColorPickerViewControllerDelegate {
    var pickingColorHandler: ((UIColor) -> Void)?
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        DispatchQueue.main.async { [weak self] in
            // convert to UIExtendedSRGBColorSpace
            var (r,g,b,a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            viewController.selectedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            let color = UIColor(red: r, green: g, blue: b, alpha: a)
            // return color
            self?.pickingColorHandler?(color)
            self?.pickingColorHandler = nil
        }
    }
}
