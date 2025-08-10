import SwiftUI

struct TransactionHistoryView: View {
    let transactions: [Transaction]
    @Environment(\.presentationMode) var presentationMode
    @State private var filteredTransactions: [Transaction] = []
    @State private var selectedFilter: TransactionFilter = .all
    @State private var searchText = ""
    
    enum TransactionFilter: String, CaseIterable {
        case all = "전체"
        case income = "입금"
        case expense = "출금"
        
        var systemImage: String {
            switch self {
            case .all: return "list.bullet"
            case .income: return "arrow.down.circle.fill"
            case .expense: return "arrow.up.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 커스텀 네비게이션 바
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("가계부")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("거래내역")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("가계부")
                        }
                        .opacity(0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
                
                // 검색 바
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("거래 내용을 검색하세요", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                
                // 필터 탭
                HStack(spacing: 0) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            applyFilters()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: filter.systemImage)
                                    .font(.caption)
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedFilter == filter ? .blue : .gray)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                selectedFilter == filter ?
                                Color.blue.opacity(0.1) :
                                Color.clear
                            )
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // 거래내역 총계
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("총 \(filteredTransactions.count)건의 거래")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        let totalAmount = calculateTotalAmount()
                        if totalAmount != 0 {
                            Text("\(totalAmount > 0 ? "+" : "")₩\(abs(totalAmount).formattedWithCommas)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(totalAmount > 0 ? .green : .red)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // 거래내역 리스트
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedTransactions, id: \.0) { date, transactions in
                            VStack(alignment: .leading, spacing: 0) {
                                // 날짜 헤더
                                HStack {
                                    Text(date)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    let dayTotal = transactions.reduce(0) { sum, transaction in
                                        sum + (transaction.type == .expense ? -transaction.amount : transaction.amount)
                                    }
                                    
                                    if dayTotal != 0 {
                                        Text("\(dayTotal > 0 ? "+" : "")₩\(abs(dayTotal).formattedWithCommas)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(dayTotal > 0 ? .green : .red)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.05))
                                
                                // 해당 날짜의 거래들
                                ForEach(transactions) { transaction in
                                    DetailedTransactionRowView(transaction: transaction)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                    
                                    if transaction.id != transactions.last?.id {
                                        Divider()
                                            .padding(.leading, 68)
                                    }
                                }
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 8)
                            }
                        }
                    }
                }
                .background(Color.white)
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarHidden(true)
            .onAppear {
                filteredTransactions = transactions.sorted { $0.date > $1.date }
            }
            .onChange(of: searchText) { _ in
                applyFilters()
            }
        }
    }
    
    // 필터 적용
    private func applyFilters() {
        var filtered = transactions
        
        switch selectedFilter {
        case .all:
            break
        case .income:
            filtered = filtered.filter { $0.type == .income }
        case .expense:
            filtered = filtered.filter { $0.type == .expense }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.counterparty.localizedCaseInsensitiveContains(searchText) ||
                $0.bankName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredTransactions = filtered.sorted { $0.date > $1.date }
    }
    
    // 총액 계산
    private func calculateTotalAmount() -> Int {
        return filteredTransactions.reduce(0) { sum, transaction in
            switch transaction.type {
            case .expense:
                return sum - transaction.amount
            case .income:
                return sum + transaction.amount
            }
        }
    }
    
    // 날짜별 거래 그룹화
    private var groupedTransactions: [(String, [Transaction])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 (E)"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            dateFormatter.string(from: transaction.date)
        }
        
        return grouped.sorted { first, second in
            guard let firstDate = grouped[first.key]?.first?.date,
                  let secondDate = grouped[second.key]?.first?.date else {
                return false
            }
            return firstDate > secondDate
        }
    }
}

struct DetailedTransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: transaction.category.color).opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: transaction.category.color))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(transaction.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(transaction.type == .expense ? "-₩\(transaction.formattedAmount)" : "+₩\(transaction.formattedAmount)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(transaction.type == .expense ? .red : .green)
                }
                
                HStack(spacing: 8) {
                    Text(transaction.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: transaction.category.color).opacity(0.1))
                        .foregroundColor(Color(hex: transaction.category.color))
                        .cornerRadius(4)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(transaction.counterparty)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(transaction.bankName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(transaction.formattedDateTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

struct TransactionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTransactions = [
            Transaction(
                amount: 25000,
                type: .expense,
                category: .food,
                description: "카페 아메리카노",
                date: Date(),
                counterparty: "윤서",
                bankName: "토스"
            ),
            Transaction(
                amount: 100000,
                type: .income,
                category: .other,
                description: "급여",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                counterparty: "회사",
                bankName: "신한SOL"
            )
        ]
        
        TransactionHistoryView(transactions: sampleTransactions)
    }
}

