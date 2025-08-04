import SwiftUI

struct TransferView: View {
    let amount: String
    let sender: String
    
    @State private var currentAmount = ""
    @State private var selectedAccount = "신한 110-987-654321"
    @Environment(\.dismiss) var dismiss
    @Binding var showTransferView: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 네비게이션
            HStack {
                Button(action: {
                    showTransferView = false
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
            
            // 메인 콘텐츠
            VStack(spacing: 0) {
                // 받는 사람 정보
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(sender)님께")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    Text("신한 110123456789")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                
                // 얼마를 보낼까요?
                VStack(spacing: 20) {
                    Text("얼마를 보낼까요?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // 송금 금액 표시
                    VStack(spacing: 8) {
                        Text(addCommasToNumber(currentAmount) + "원")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(convertToKoreanAmount(currentAmount))
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.02))
                
                // 하단 고정 영역
                VStack(spacing: 0) {
                    // 계좌 선택
                    HStack {
                        Text("신한 110-214-203626")
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
                    
                    // 금액 버튼들
                    HStack(spacing: 8) {
                        Button("+1만") {
                            addAmount(10000)
                        }
                        .frame(minWidth: 50, minHeight: 35)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(18)
                        
                        Button("+5만") {
                            addAmount(50000)
                        }
                        .frame(minWidth: 50, minHeight: 35)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(18)
                        
                        Button("+10만") {
                            addAmount(100000)
                        }
                        .frame(minWidth: 55, minHeight: 35)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(18)
                        
                        Button("+100만") {
                            addAmount(1000000)
                        }
                        .frame(minWidth: 60, minHeight: 35)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(18)
                        
                        Button("전액") {
                            setMaxAmount()
                        }
                        .frame(minWidth: 45, minHeight: 35)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(18)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    
                    // 키패드
                    NumberPadView(currentAmount: $currentAmount)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            currentAmount = amount
            print("💰 송금 화면 로드: \(amount)원, 발송자: \(sender)")
        }
    }
    
    // 금액 추가 함수
    private func addAmount(_ amount: Int) {
        let current = Int(currentAmount) ?? 0
        currentAmount = String(current + amount)
    }
    
    // 전액 설정
    private func setMaxAmount() {
        currentAmount = "3166346" // 계좌 잔액
    }
    
    // 숫자에 콤마 추가 (완전히 새로운 함수)
    private func addCommasToNumber(_ numberString: String) -> String {
        guard let number = Int(numberString), number > 0 else { return "0" }
        
        let str = String(number)
        var result = ""
        
        for (index, char) in str.enumerated() {
            if index > 0 && (str.count - index) % 3 == 0 {
                result += ","
            }
            result += String(char)
        }
        
        return result
    }
    
    // 한글 금액 변환 (완전히 새로운 함수)
    private func convertToKoreanAmount(_ numberString: String) -> String {
        guard let number = Int(numberString), number > 0 else { return "" }
        
        if number >= 10000 {
            let manPart = number / 10000
            let remainder = number % 10000
            
            if remainder == 0 {
                return "\(manPart)만원"
            } else {
                return "\(manPart)만\(remainder)원"
            }
        } else {
            return "\(number)원"
        }
    }
}

// 숫자 키패드
struct NumberPadView: View {
    @Binding var currentAmount: String
    
    let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["←", "0", "완료"]
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<numbers.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<numbers[row].count, id: \.self) { col in
                        Button(action: {
                            handleKeyPad(numbers[row][col])
                        }) {
                            if numbers[row][col] == "←" {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .frame(height: 60)
                            } else {
                                Text(numbers[row][col])
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(numbers[row][col] == "완료" ? .blue : .black)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .frame(height: 60)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private func handleKeyPad(_ key: String) {
        switch key {
        case "완료":
            // 송금 완료 처리
            print("✅ 송금 완료: \(currentAmount)원")
        case "←":
            // 백스페이스 처리
            if !currentAmount.isEmpty {
                currentAmount = String(currentAmount.dropLast())
            }
        default:
            // 숫자 입력 처리
            currentAmount += key
            print("🔢 현재 금액: \(currentAmount)")
        }
    }
}

#Preview {
    TransferView(amount: "25000", sender: "조윤서", showTransferView: .constant(true))
}
