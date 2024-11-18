//
//  MessageManager.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 18.11.2024.
//

import UIKit
import MessageUI


final class MessageManager: NSObject, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    struct Mail {
        struct Attachment {
            let data: Data
            let mimeType: String
            let filename: String
        }
        
        let body: String
        let isHTML: Bool
        var subject: String? = nil
        var recipients: [String] = []
        var attachment: Attachment? = nil
    }
    
    struct Message {
        let body: String
        var recipients: [String] = []
        var fileURL: URL? = nil
    }
    
    static let shared = MessageManager()
    override private init() {}
    
    private weak var viewController: UIViewController? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first(where: \.isKeyWindow)
        return window?.rootViewController
    }
    
    private var sendMailCompletion: ((MFMailComposeResult) -> Void)?
    private var sendMessageCompletion: ((MessageComposeResult) -> Void)?
    
    var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    var canSendMessage: Bool {
        MFMessageComposeViewController.canSendText()
    }
    
    func sendMessage(_ message: Message, completion: ((MessageComposeResult) -> Void)? = nil) {
        sendMessageCompletion = nil
        guard let viewController, canSendMessage else { completion?(.failed); return }
        
        sendMessageCompletion = completion
        
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.popoverPresentationController?.sourceView = viewController.view
        messageController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 1, height: 1)
        
        messageController.body = message.body
        messageController.recipients = message.recipients
        if let fileURL = message.fileURL {
            messageController.addAttachmentURL(fileURL, withAlternateFilename: fileURL.lastPathComponent)
        }
        viewController.present(messageController, animated: true)
    }
    
    func sendMail(_ mail: Mail, completion: ((MFMailComposeResult) -> Void)? = nil) {
        sendMailCompletion = nil
        guard let viewController, canSendMail else { completion?(.failed); return }
        
        sendMailCompletion = completion
        
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.popoverPresentationController?.sourceView = viewController.view
        mailController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 1, height: 1)
        
        mailController.setToRecipients(mail.recipients)
        mailController.setMessageBody("<p>\(mail.body)</p>", isHTML: true)
        if let subject = mail.subject {
            mailController.setSubject(subject)
        }
        if let attachment = mail.attachment {
            mailController.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.filename)
        }
        viewController.present(mailController, animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) { [weak self] in
            self?.sendMessageCompletion?(result)
            self?.sendMessageCompletion = nil
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            self?.sendMailCompletion?(result)
            self?.sendMailCompletion = nil
        }
    }
}
