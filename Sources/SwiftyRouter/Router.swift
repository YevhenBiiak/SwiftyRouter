//
//  Router.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 18.11.2024.
//

import SwiftUI


public struct Router {
    
    public static var logEnabled = true
    
    public private(set) weak var viewController: UIViewController?
    
    public init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}


// MARK: Push - Pop

extension Router {
    
    public func push<T: View>(_ view: T, animated: Bool = true, allowsSwipeBack: Bool = true, completion: (() -> Void)? = nil) {
        let controller = RouterHostingController(rootView: view, allowsSwipeBack: allowsSwipeBack)
        viewController?.navigationController?.pushViewController(controller, animated: animated, completion: completion)
    }
    
    public func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.navigationController?.popViewController(animated: animated, completion: completion)
    }
    
    public func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.navigationController?.popToRootViewController(animated: animated, completion: completion)
    }
}


// MARK: Present - Dismiss

extension Router {
    
    public func present<T>(_ view: T, style: UIModalPresentationStyle = .automatic, animated: Bool = true) where T : View {
        let controller = RouterHostingController(rootView: view)
        controller.modalPresentationStyle = style
        viewController?.present(controller, animated: animated)
    }
    
    public func present<T: View>(_ view: T, style: UIModalPresentationStyle, transition: CATransition) {
        let controller = RouterHostingController(rootView: view)
        controller.modalPresentationStyle = style
        viewController?.view.window?.layer.add(transition, forKey: kCATransition)
        viewController?.present(controller, animated: false)
    }
    
    public func present<T: View>(_ view: T, style: UIModalPresentationStyle, transition: UIModalTransitionStyle) {
        let controller = RouterHostingController(rootView: view)
        controller.modalPresentationStyle = style
        controller.modalTransitionStyle = transition
        viewController?.present(controller, animated: true)
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.dismiss(animated: animated, completion: completion)
    }
    
    public func dismiss(transition: UIModalTransitionStyle, completion: (() -> Void)? = nil) {
        viewController?.modalTransitionStyle = transition
        viewController?.dismiss(animated: true, completion: completion)
    }
}


// MARK: Alert

extension Router {
    
    public func alert<A>(_ title: String?, message: String? = nil, style: UIAlertController.Style = .alert, @ViewBuilder actions: @escaping () -> A) where A: View {
        let alertView = AlertView(title: title, message: message, actions: actions, style: style)
        self.present(alertView, style: .overFullScreen, animated: false)
    }
}


// MARK: Activity

extension Router {
    
    public func activity(items: [String]) {
        presentActivityViewController(with: items)
    }
    
    public func activity(items: [Data], title: String? = nil, subtitle: String? = nil, icon: UIImage? = nil) {
        var activityItems: [Any]
        if title == nil && subtitle == nil && icon == nil {
            activityItems = items as [Any]
        } else {
            if items.count == 1 {
                activityItems = [ActivityItem(item: items.first as Any, title: title, subtitle: subtitle, image: icon)]
            } else {
                let first = items.dropLast() as [Any]
                let last = ActivityItem(item: items.last as Any, title: title, subtitle: subtitle, image: icon) as Any
                activityItems = first + [last]
            }
        }
        presentActivityViewController(with: activityItems)
    }
    
    public func activity(items: [URL], title: String? = nil, subtitle: String? = nil, icon: UIImage? = nil) {
        var activityItems: [Any]
        if title == nil && subtitle == nil && icon == nil {
            if items.count == 1 && items.first!.isFileURL {
                activityItems = [NSItemProvider(contentsOf: items.first!) as Any]
            } else {
                activityItems = items as [Any]
            }
        } else {
            if items.count == 1 {
                activityItems = [ActivityItem(item: items.first as Any, title: title, subtitle: subtitle, image: icon)]
            } else {
                let first = items.dropLast() as [Any]
                let last = ActivityItem(item: items.last as Any, title: title, subtitle: subtitle, image: icon) as Any
                activityItems = first + [last]
            }
        }
        presentActivityViewController(with: activityItems)
    }
    
    private func presentActivityViewController(with activityItems: [Any]) {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if #available(iOS 16.0, *) {
            controller.popoverPresentationController?.sourceItem = viewController?.view
        } else {
            controller.popoverPresentationController?.sourceView = viewController?.view
        }
        controller.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 1, height: 1)
        viewController?.present(controller, animated: true)
    }
}


// MARK: Printer

extension Router {
    
    public func print(jobName: String? = nil, items: [URL]) {
        let printInfo = UIPrintInfo(dictionary: nil)
        if let jobName { printInfo.jobName = jobName }
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItems = items
        printController.present(animated: true)
    }
    
    public func print(jobName: String? = nil, items: [Data]) {
        let printInfo = UIPrintInfo(dictionary: nil)
        if let jobName { printInfo.jobName = jobName }
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItems = items
        printController.present(animated: true)
    }
    
    public func print(jobName: String? = nil, formatter: UIPrintFormatter) {
        let printInfo = UIPrintInfo(dictionary: nil)
        if let jobName { printInfo.jobName = jobName }
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printFormatter = formatter
        printController.present(animated: true)
    }
}


// MARK: ColorPicker

extension Router {
    
    public func colorPicker(_ title: String? = nil, completion: @escaping (UIColor) -> Void) {
        ColorPickerHelper.pick(on: viewController, title: title, completion: completion)
    }
}


// MARK: FilePicker

extension Router {
    /// File picker. ⚠️ **Warning**: Do not forget to handle with `startAccessingSecurityScopedResource`.
    ///
    /// - Parameters:
    ///   - types: [UTType]
    ///   - allowsMultipleSelection: Bool
    ///   - title: String?
    ///   - completion: (([URL]) -> Void)?
    ///
    /// # Example #
    /// ```swift
    /// if url.startAccessingSecurityScopedResource() {
    ///     defer { url.stopAccessingSecurityScopedResource() }
    ///
    ///     do {
    ///         let data = try Data(contentsOf: url)
    ///         // Process data...
    ///     } catch {
    ///         print("Error accessing file: \(error)")
    ///     }
    /// } else {
    ///     print("Failed to start accessing security scoped resource.")
    /// }
    /// ```
    ///
    /// Always call `stopAccessingSecurityScopedResource` to release the resource when done.
    /// Failing to do so may lead to resource leaks or unexpected behavior.
    public func filePicker(types: [UTType], allowsMultipleSelection: Bool = false, title: String? = nil, completion: (([URL]) -> Void)?) {
        FilePickerHelper.pick(types: types, allowsMultipleSelection: allowsMultipleSelection, on: viewController, title: title, completion: completion)
    }
}

// MARK: Mail / Message

import MessageUI
extension Router {
    
    public func sendMail(text: String, recipients: [String], subject: String, completion: ((MFMailComposeResult) -> Void)? = nil) {
        let mail = MailMessageHelper.Mail(body: text, isHTML: false, subject: subject, recipients: recipients, attachment: nil)
        MailMessageHelper.shared.sendMail(mail, completion: completion)
    }
    
    public func sendMail(html: String, recipients: [String], subject: String, completion: ((MFMailComposeResult) -> Void)? = nil) {
        let mail = MailMessageHelper.Mail(body: html, isHTML: true, subject: subject, recipients: recipients, attachment: nil)
        MailMessageHelper.shared.sendMail(mail, completion: completion)
    }
    
    public func sendMessage(text: String, recipients: [String], subject: String, completion: ((MessageComposeResult) -> Void)? = nil) {
        let message = MailMessageHelper.Message(body: text, recipients: recipients, fileURL: nil)
        MailMessageHelper.shared.sendMessage(message, completion: completion)
    }
}


// MARK: Other

import Photos
import StoreKit
extension Router {
    
    public func saveImage(_ image: UIImage, completion: ((Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion?(nil)
                } else {
                    completion?(error)
                }
            }
        }
    }
    
    public func saveImage(url: URL, completion: ((Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion?(nil)
                } else {
                    completion?(error)
                }
            }
        }
    }
    
    public func saveVideo(url: URL, completion: ((Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion?(nil)
                } else {
                    completion?(error)
                }
            }
        }
    }
    
    public func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    public func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            self.openURL(string: url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    public func openURL(string: String) {
        if let url = URL(string: string.trimmingCharacters(in: .whitespacesAndNewlines)) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    public func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 16.0, *) {
                Task { await AppStore.requestReview(in: scene) }
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
