//
//  SOL_settleApp.swift
//  SOL-settle
//
//  Created by 조윤서 on 8/3/25.
//

import SwiftUI

@main
struct SOL_settleApp: App {
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
}
