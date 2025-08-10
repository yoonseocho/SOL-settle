import Foundation
import SwiftUI
// 거래 유형
enum TransactionType: String, CaseIterable, Codable {
    case expense = "지출"
    case income = "수입"
}
// 거래 카테고리
enum TransactionCategory: String, CaseIterable, Codable {
    case food = "식비"
    case transport = "교통"
    case shopping = "쇼핑"
    case gift = "선물"
    case travel = "여행"
    case transfer = "이체"
    case other = "기타"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .gift: return "gift.fill"
        case .travel: return "airplane"
        case .transfer: return "arrow.left.arrow.right"
        case .other: return "ellipsis"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "#FF6B6B"
        case .transport: return "#4ECDC4"
        case .shopping: return "#45B7D1"
        case .gift: return "#FFB347"
        case .travel: return "#96CEB4"
        case .transfer: return "arrow.left.arrow.right"
        case .other: return "#B0BEC5"
        }
    }
}
// 거래 내역
struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Int
    let type: TransactionType
    let category: TransactionCategory
    let description: String
    let date: Date
    let counterparty: String
    let bankName: String
    let time: String
    
    init(amount: Int, type: TransactionType, category: TransactionCategory, description: String, date: Date, counterparty: String, bankName: String, time: String = "") {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.category = category
        self.description = description
        self.date = date
        self.counterparty = counterparty
        self.bankName = bankName
        self.time = time.isEmpty ? DateFormatter.timeFormatter.string(from: date) : time
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: date)
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var displayAmount: String {
        switch type {
        case .expense:
            return "-₩\(formattedAmount)"
        case .income:
            return "+₩\(formattedAmount)"
        }
    }
    
    var amountColor: Color {
        switch type {
        case .expense:
            return .red
        case .income:
            return .blue
        }
    }
}
// 카테고리 요약
struct CategorySummary: Identifiable {
    let id = UUID()
    let category: TransactionCategory
    let totalAmount: Int
    let percentage: Double
}
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

extension Notification.Name {
    static let transactionAdded = Notification.Name("transactionAdded")
}

// 잔액 공유를 위한 ObservableObject
class BalanceManager: ObservableObject {
    @Published var currentBalance: Int = 5250
    
    static let shared = BalanceManager()
    
    private init() {}
}
