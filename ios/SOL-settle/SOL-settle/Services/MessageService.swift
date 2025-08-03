import MessageUI

// MessageService.swift에 추가
class MessageService: NSObject, MFMessageComposeViewControllerDelegate {
    func sendSMS(to phoneNumbers: [String], message: String, from viewController: UIViewController) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            messageVC.recipients = phoneNumbers
            messageVC.body = message
            
            viewController.present(messageVC, animated: true)
        } else {
            print("SMS 발송 불가능")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
