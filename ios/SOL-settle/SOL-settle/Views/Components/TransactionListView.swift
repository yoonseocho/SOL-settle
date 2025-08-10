import SwiftUI

struct TransactionListView: View {
    let transactions: [Transaction]
    @State private var showContactSelection = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedAmount: Int = 0
    @State private var selectedDescription: String = ""
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                let dayTransactions = groupedTransactions[date] ?? []
                
                // 날짜 헤더
                VStack(spacing: 0) {
                    HStack {
                        Text(formatDateHeader(date))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#F8F8F8"))
                    
                    // 해당 날짜의 거래내역들
                    ForEach(Array(dayTransactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowWithButton(
                            transaction: transaction,
                            onSettlementTap: {
                                print("🔥 정산하기 버튼 탭됨!")
                                print("🔍 거래 정보:")
                                print("   - amount: \(transaction.amount)")
                                print("   - description: '\(transaction.description)'")
                                print("   - type: \(transaction.type)")
                                print("🎯 정산하기 탭 - 거래 설정 중...")
                                print("   - 선택된 거래: \(transaction.description), \(transaction.amount)원")
                                
                                DispatchQueue.main.async {
                                    selectedTransaction = transaction
                                    selectedAmount = transaction.amount
                                    selectedDescription = transaction.description
                                    
                                    print("   - 값 설정 완료")
                                    print("   - selectedAmount: \(selectedAmount)")
                                    print("   - selectedDescription: '\(selectedDescription)'")
                                    
                                    showContactSelection = true
                                    print("   - showContactSelection = true")
                                }
                            }
                        )
                        
                        if index < dayTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .fullScreenCover(isPresented: $showContactSelection) {
            if selectedAmount > 0 && !selectedDescription.isEmpty {
                ContactSelectionView(
                    presetAmount: selectedAmount > 0 ? selectedAmount : nil,
                    presetDescription: !selectedDescription.isEmpty ? selectedDescription : nil,
                    onDismiss: {
                        showContactSelection = false
                    }
                )
            } else {
                ContactSelectionView(
                    onDismiss: {
                        showContactSelection = false
                    }
                )
            }
        }
        .onChange(of: showContactSelection) { isShowing in
            if !isShowing {
                // 🆕 sheet가 닫힐 때 값들을 초기화
                print("🔄 sheet 닫힘 - 값들 초기화")
                selectedAmount = 0
                selectedDescription = ""
                selectedTransaction = nil
            }
        }
    }
    
    private var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: transaction.date)
        }
    }
    
    private func formatDateHeader(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - 정산 버튼이 있는 거래 행
struct TransactionRowWithButton: View {
    let transaction: Transaction
    let onSettlementTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(transaction.time)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text(transaction.counterparty)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(transaction.type.rawValue)
                                .font(.system(size: 12))
                                .foregroundColor(transaction.type == .expense ? .red :
                                               transaction.type == .income ? .blue : .primary)
                            
                            Text(transaction.displayAmount)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(transaction.amountColor)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Text(transaction.description)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        // 카테고리 표시
                        if transaction.category != .other {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: transaction.category.color))
                                    .frame(width: 8, height: 8)
                                
                                Text(transaction.category.rawValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        
                        Spacer()
                        
                        // 🆕 정산하기 버튼 (지출 거래에만)
                        if transaction.type == .expense {
                            Button(action: onSettlementTap) {
                                Text("정산하기")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTransactions = [
            Transaction(
                amount: 4912,
                type: .expense,
                category: .food,
                description: "전혜림",
                date: Calendar.current.date(byAdding: .day, value: -11, to: Date()) ?? Date(),
                counterparty: "타행모바일뱅킹",
                bankName: "신한은행",
                time: "22:46:01"
            ),
            Transaction(
                amount: 5200,
                type: .expense,
                category: .transport,
                description: "김민수",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                counterparty: "타행모바일뱅킹",
                bankName: "신한은행",
                time: "08:12:45"
            ),
            Transaction(
                amount: 15000,
                type: .expense,
                category: .food,
                description: "김민수",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                counterparty: "타행모바일뱅킹",
                bankName: "신한은행",
                time: "13:25:40"
            ),
            Transaction(
                amount: 8700,
                type: .expense,
                category: .food,
                description: "박지현",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                counterparty: "타행모바일뱅킹",
                bankName: "신한은행",
                time: "19:05:12"
            ),
            Transaction(
                amount: 23000,
                type: .expense,
                category: .food,
                description: "오세영",
                date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
                counterparty: "타행모바일뱅킹",
                bankName: "신한은행",
                time: "18:42:59"
            ),
            Transaction(
                amount: 6500,
                type: .expense,
                category: .food,
                description: "김밥천국",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                counterparty: "신한카드",
                bankName: "신한은행",
                time: "12:20:15"
            ),
            Transaction(
                amount: 4200,
                type: .expense,
                category: .food,
                description: "스타벅스",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                counterparty: "신한카드",
                bankName: "신한은행",
                time: "09:10:05"
            ),
            Transaction(
                amount: 11000,
                type: .expense,
                category: .food,
                description: "맥도날드",
                date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                counterparty: "신한카드",
                bankName: "신한은행",
                time: "18:45:32"
            ),
            Transaction(
                amount: 8900,
                type: .expense,
                category: .food,
                description: "교촌치킨",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                counterparty: "신한카드",
                bankName: "신한은행",
                time: "20:05:12"
            ),
            Transaction(
                amount: 100000,
                type: .income,
                category: .transfer,
                description: "용돈",
                date: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
                counterparty: "타행모바일뱅킹",
                bankName: "신한은행",
                time: "06:35:04"
            )
        ]
        
        TransactionListView(transactions: sampleTransactions)
            .padding()
    }
}
