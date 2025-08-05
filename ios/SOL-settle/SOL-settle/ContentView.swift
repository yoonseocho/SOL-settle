import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "sol_settlement" {
            if let amount = userInfo["amount"] as? Int,
               let sender = userInfo["sender"] as? String {
                
                NotificationCenter.default.post(
                    name: .showTransferView,
                    object: nil,
                    userInfo: [
                        "amount": String(amount),
                        "sender": sender
                    ]
                )
            }
        }
        
        completionHandler()
    }
}

struct ContentView: View {
    @State private var showTransferView = false
    @State private var transferAmount = ""
    @State private var senderName = ""
    @StateObject private var notificationDelegate = NotificationDelegate()
    
    var body: some View {
        NavigationView {
            if showTransferView {
                TransferView(amount: transferAmount, sender: senderName, showTransferView: $showTransferView)
            } else {
                MainView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTransferView)) { notification in
            if let userInfo = notification.userInfo,
               let amount = userInfo["amount"] as? String,
               let sender = userInfo["sender"] as? String {
                self.transferAmount = amount
                self.senderName = sender
                self.showTransferView = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAllTransferViews)) { _ in
            // 송금 완료 후 메인 화면으로 돌아가기
            self.showTransferView = false
        }
        .onAppear {
            UNUserNotificationCenter.current().delegate = notificationDelegate
        }
    }
}

// Notification 확장
extension Notification.Name {
    static let showTransferView = Notification.Name("showTransferView")
    static let dismissAllTransferViews = Notification.Name("dismissAllTransferViews")
}

#Preview {
    ContentView()
}
