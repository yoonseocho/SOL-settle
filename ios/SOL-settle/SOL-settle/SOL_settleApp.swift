//
//  SOL_settleApp.swift
//  SOL-settle
//
//  Created by 조윤서 on 8/3/25.
//

import SwiftUI
import UserNotifications

@main
struct SOL_settleApp: App {
    init() {
        setupNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 딥링크 수신: \(url.absoluteString)")
        
        // solsettle://transfer?amount=15000&sender=조윤서
        guard url.scheme == "solsettle",
              url.host == "transfer" else {
            print("❌ 잘못된 딥링크 형식")
            return
        }
        
        // URL 파라미터 파싱
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var amount = ""
        var sender = ""
        
        if let queryItems = components?.queryItems {
            for item in queryItems {
                switch item.name {
                case "amount":
                    amount = item.value ?? ""
                case "sender":
                    sender = item.value ?? ""
                default:
                    break
                }
            }
        }
        
        print("💰 송금 금액: \(amount)")
        print("👤 발송자: \(sender)")
        
        // ContentView에게 알림 전송
        NotificationCenter.default.post(
            name: .showTransferView,
            object: nil,
            userInfo: ["amount": amount, "sender": sender]
        )
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                print("🔔 푸시 알림 권한: \(granted)")
                if let error = error {
                    print("❌ 권한 요청 오류: \(error)")
                }
            }
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // 푸시 알림을 탭했을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("🔔 푸시 알림 탭됨 - UserInfo: \(userInfo)")
        print("🔔 Response identifier: \(response.actionIdentifier)")
        
        // userInfo가 비어있으면 하드코딩된 값으로 테스트
        if userInfo.isEmpty {
            print("⚠️ userInfo가 비어있음 - 하드코딩 값으로 테스트")
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .showTransferView,
                    object: nil,
                    userInfo: ["amount": "16666", "sender": "조세현"]
                )
            }
        } else {
            // SOL 정산 알림인지 확인
            if let type = userInfo["type"] as? String, type == "sol_settlement" {
                if let amount = userInfo["amount"] as? Int,
                   let sender = userInfo["sender"] as? String {
                    
                    print("💰 정산 알림 처리: \(amount)원, 발송자: \(sender)")
                    
                    // NotificationCenter로 ContentView에 알림 전송 (즉시 실행)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: .showTransferView,
                            object: nil,
                            userInfo: ["amount": String(amount), "sender": sender]
                        )
                    }
                } else {
                    print("❌ amount 또는 sender 파싱 실패")
                }
            } else {
                print("❌ type이 sol_settlement가 아니거나 없음")
            }
        }
        
        completionHandler()
    }
}
