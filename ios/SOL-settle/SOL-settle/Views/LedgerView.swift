import SwiftUI
struct LedgerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var transactions: [Transaction] = []
    @State private var categorySummaries: [CategorySummary] = []
    @State private var totalExpense: Int = 0
    @StateObject private var balanceManager = BalanceManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // SOL 스타일 헤더
                    VStack(spacing: 0) {
                        HStack {
                            HStack(spacing: 8) {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Text("거래내역조회")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: {}) {
                                    Image(systemName: "message")
                                        .font(.system(size: 20))
                                        .foregroundColor(.primary)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "mic")
                                        .font(.system(size: 20))
                                        .foregroundColor(.primary)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "house")
                                        .font(.system(size: 20))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                    .background(Color.white)
                    
                    // 계좌 정보 영역
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: "#0046FF"))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("S")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("입출금")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("쏠편한 입출금통장")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 18))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Text("(저축예금)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text("신한 110-123-456789")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // 잔액 표시
                        VStack(spacing: 8) {
                            Text("₩\(formattedAmount(balanceManager.currentBalance))")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("출금가능금액 ₩\(formattedAmount(balanceManager.currentBalance))")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // 이체, 계좌관리 버튼
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                Text("이체")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#E8F0FF"))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {}) {
                                Text("계좌관리")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#E8F0FF"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "#F0F6FF"))
                    
                    // 필터 영역
                    VStack(spacing: 16) {
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("1개월")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                
                                Text("·")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Text("전체")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                
                                Text("·")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Text("최신순")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            Text("2025.07.10 ~ 2025.08.10 (10건)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Toggle("", isOn: .constant(false))
                                .labelsHidden()
                                .scaleEffect(0.8)
                            
                            Text("잔액")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    
                    // 거래내역 리스트
                    TransactionListView(transactions: transactions)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(hex: "#F5F5F5"))
            .onAppear {
                loadSampleData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .transactionAdded)) { _ in
                loadSampleData() // 새로운 거래가 추가되면 데이터 새로고침
            }
            .onReceive(NotificationCenter.default.publisher(for: .calculateBalance)) { _ in
                loadSampleData() // MainView에서 요청하면 계산 실행
            }
        }
        .navigationBarHidden(true)
    }
    
    private func loadSampleData() {
        // 저장된 실제 거래내역 불러오기
        let storedTransactions = getStoredTransactions()
        
        // 실제 SOL 앱과 유사한 거래내역 데이터
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
                amount: 50000,
                type: .income,
                category: .transfer,
                description: "용돈",
                date: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
                counterparty: "타행모바일뱅킹",
                bankName: "신한은행",
                time: "06:35:04"
            )
        ]
        
        // 저장된 거래내역과 샘플 데이터 합치기
        transactions = sampleTransactions + storedTransactions
        
        // 조윤서 관련 거래 제외
        transactions = transactions.filter { $0.description != "조윤서" }
        
        // 날짜순으로 정렬
        transactions.sort { $0.date > $1.date }
        
        // 총 지출 계산
        totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        // 계좌 잔액 계산 (시작 잔액 + 수입 - 지출)
        let startingBalance = 5250  // 초기 잔액
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        balanceManager.currentBalance = startingBalance + totalIncome - totalExpenses
        
        // 카테고리별 요약 생성
        generateCategorySummaries()
    }
    
    private func generateCategorySummaries() {
        let expenseTransactions = transactions.filter { $0.type == .expense }
        let groupedByCategory = Dictionary(grouping: expenseTransactions) { $0.category }
        
        categorySummaries = groupedByCategory.map { category, transactions in
            let totalAmount = transactions.reduce(0) { $0 + $1.amount }
            let percentage = totalExpense > 0 ? (Double(totalAmount) / Double(totalExpense)) * 100 : 0
            
            return CategorySummary(
                category: category,
                totalAmount: totalAmount,
                percentage: percentage
            )
        }
        .sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
    
    private func getStoredTransactions() -> [Transaction] {
        guard let data = UserDefaults.standard.data(forKey: "ActualTransactions") else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return (try? decoder.decode([Transaction].self, from: data)) ?? []
    }
}
// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
struct LedgerView_Previews: PreviewProvider {
    static var previews: some View {
        LedgerView()
    }
}

