import SwiftUI

struct ContentView: View {
    @State private var showTransferView = false
    @State private var transferAmount = ""
    @State private var senderName = ""
    
    var body: some View {
        NavigationView {
            if showTransferView {
                TransferView(amount: transferAmount, sender: senderName, showTransferView: $showTransferView)
            } else {
                MainView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTransferView)) { notification in
            print("📱 ContentView: showTransferView 알림 수신")
            if let userInfo = notification.userInfo,
               let amount = userInfo["amount"] as? String,
               let sender = userInfo["sender"] as? String {
                print("📱 ContentView: 송금 화면 표시 - 금액: \(amount), 발송자: \(sender)")
                self.transferAmount = amount
                self.senderName = sender
                self.showTransferView = true
            } else {
                print("❌ ContentView: userInfo 파싱 실패")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAllTransferViews)) { _ in
            // 송금 완료 후 메인 화면으로 돌아가기
            self.showTransferView = false
        }
        .onAppear {
            // 앱 시작시 필요한 설정은 SOL_settleApp에서 처리
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
