import SwiftUI

struct TransferDetailView: View {
    let amount: String
    let sender: String
    let recipient: String
    
    @State private var memo = ""
    @State private var selectedSender = "김수진"
    @State private var selectedRecipient = "조윤서"
    @State private var navigateToComplete = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 네비게이션
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Image(systemName: "message")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Image(systemName: "mic")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Image(systemName: "house")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 0) {
                    // 받는 사람 정보
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(recipient)님께")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        Text("신한 110-987-654321")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    
                    // 송금 금액 강조 표시
                    VStack(spacing: 10) {
                        Text(formatAmountWithCommas(amount) + "원")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("보낼까요?")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.02))
                    
                    // 하단 폼 영역
                    VStack(spacing: 0) {
                        // 계좌 정보
                        HStack {
                            Text("신한 110-987-654321")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("3,166,346원")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.05))
                        
                        // 입력 필드들
                        VStack(spacing: 0) {
                            // 받을분 메모
                            HStack {
                                Text("받을분 메모")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("조윤서")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // 내통장 메모
                            HStack {
                                Text("내통장 메모")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("김수진")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // 수수료
                            HStack {
                                Text("수수료")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("면제")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(Color.white)
                        }
                        .background(Color.white)
                        
                        // 추가정보 토글
                        Button(action: {
                            // 추가정보 토글 기능
                        }) {
                            HStack {
                                Text("추가정보")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                        }
                        .background(Color.white)
                        
                        // 여백
                        Color.clear.frame(height: 100)
                    }
                }
            }
            .background(Color.gray.opacity(0.05))
        }
        .overlay(
            // 하단 버튼들
            VStack {
                Spacer()
                
                // 취소/이체 버튼
                HStack(spacing: 15) {
                    Button("추가이체") {
                        // 추가이체 기능
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(25)
                    .foregroundColor(.black)
                    
                    Button("이체") {
                        navigateToComplete = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        )
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $navigateToComplete) {
            TransferCompleteView(
                amount: amount,
                recipient: recipient,
                onDismiss: {
                    navigateToComplete = false
                    NotificationCenter.default.post(name: .dismissAllTransferViews, object: nil)
                }
            )
        }
    }
    
    // 숫자에 콤마 추가하는 함수
    private func formatAmountWithCommas(_ numberString: String) -> String {
        guard let number = Int(numberString), number > 0 else { return "0" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? numberString
    }
}

// 송금 완료 화면 - 간단한 카테고리 토글 추가
struct TransferCompleteView: View {
    let amount: String
    let recipient: String
    let onDismiss: () -> Void
    
    @State private var enableCategorySelection = false
    @State private var selectedCategory: TransactionCategory = .food
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 성공 아이콘
            Circle()
                .fill(Color.blue)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // 완료 메시지
            VStack(spacing: 15) {
                Text("송금 완료")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(formatAmountWithCommas(amount))원이")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("\(recipient)님께 송금되었습니다")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 카테고리 선택 토글 (선택사항)
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🏷️ 카테고리 설정")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("가계부 관리에 도움됩니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $enableCategorySelection)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal, 20)
                
                // 토글이 켜져있을 때만 카테고리 선택 표시
                if enableCategorySelection {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TransactionCategory.simpleCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                            .font(.caption)
                                        Text(category.displayName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedCategory == category ? category.color : Color.gray.opacity(0.15))
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .animation(.easeInOut(duration: 0.3), value: enableCategorySelection)
                }
            }
            
            // 확인 버튼
            Button("확인") {
                if enableCategorySelection {
                    saveTransactionCategory()
                }
                onDismiss()
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .cornerRadius(25)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.white)
    }
    
    // 함수들은 그대로 유지
    private func formatAmountWithCommas(_ numberString: String) -> String {
        guard let number = Int(numberString), number > 0 else { return "0" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? numberString
    }
    
    private func saveTransactionCategory() {
        let finalCategory = selectedCategory.displayName
        
        print("💾 거래 카테고리 저장:")
        print("  금액: \(amount)원")
        print("  받는이: \(recipient)")
        print("  카테고리: \(finalCategory)")
        print("  시간: \(Date())")
        
        var transactions = UserDefaults.standard.array(forKey: "SavedTransactions") as? [[String: Any]] ?? []
        
        let transaction: [String: Any] = [
            "id": UUID().uuidString,
            "amount": amount,
            "recipient": recipient,
            "category": finalCategory,
            "date": Date(),
            "type": "transfer"
        ]
        
        transactions.append(transaction)
        UserDefaults.standard.set(transactions, forKey: "SavedTransactions")
    }
}

enum TransactionCategory: String, CaseIterable {
    case food = "식비"
    case gift = "선물"
    case transport = "교통비"
    case travel = "여행"  // "여행/숙박" → "여행"으로 변경
    case etc = "기타"     // 이 라인 추가
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .gift: return "gift"
        case .transport: return "car"
        case .travel: return "airplane"
        case .etc: return "ellipsis.circle"  // 이 케이스 추가
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .gift: return .pink
        case .transport: return .blue
        case .travel: return .green
        case .etc: return .gray  // 이 케이스 추가
        }
    }
    
    // simpleCases 수정
    static var simpleCases: [TransactionCategory] {
        return [.food, .gift, .transport, .travel, .etc]  // .culture 제거, .etc 추가
    }
}

#Preview {
    TransferDetailView(
        amount: "25000",
        sender: "김수진",
        recipient: "조윤서"
    )
}
