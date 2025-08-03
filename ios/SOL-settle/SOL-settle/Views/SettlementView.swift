import SwiftUI
import MessageUI

struct SettlementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedContacts: [Contact]
    @StateObject private var contactService = ContactService()
    
    init(initialContacts: [Contact]) {
        self._selectedContacts = State(initialValue: initialContacts)
    }
    
    @State private var totalAmount = ""
    @State private var displayAmount = "" // 표시용 (콤마 포함)
    @FocusState private var isTextFieldFocused: Bool
    @State private var showConfirmationSheet = false
    @State private var showMessageComposer = false
    
    private func removeContact(_ contactId: String) {
        selectedContacts.removeAll { $0.id == contactId }
    }
    
    // 숫자 포맷팅 함수들
    private func formatNumber(_ input: String) -> String {
        let numbersOnly = input.filter { $0.isNumber }
        guard let number = Int(numbersOnly) else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    private func getNumbersOnly(_ input: String) -> String {
        return input.filter { $0.isNumber }
    }
    
    // 계산된 값들
    var participantCount: Int {
        selectedContacts.count
    }
    
    var amountPerPerson: Int {
        guard let total = Int(totalAmount), total > 0 else { return 0 }
        return total / participantCount
    }
    
    var remainder: Int {
        guard let total = Int(totalAmount), total > 0 else { return 0 }
        return total % participantCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 상단 네비게이션 (고정)
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("정산하기(1차)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("차수추가") {
                        // 차수추가 기능
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color.white)
                
                // 스크롤 가능한 콘텐츠
                ScrollView {
                    VStack(spacing: 20) {
                        // 금액 입력 섹션
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("금액입력(원)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            Text("최대 500만원까지 입력 가능")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("금액입력(원)", text: $displayAmount)
                                .font(.title2)
                                .keyboardType(.numberPad)
                                .focused($isTextFieldFocused)
                                .onChange(of: displayAmount) { newValue in
                                    let numbersOnly = getNumbersOnly(newValue)
                                    totalAmount = numbersOnly
                                    displayAmount = formatNumber(numbersOnly)
                                }
                            
                            Divider()
                            
                            // 1/N 계산 결과 표시
                            if !totalAmount.isEmpty && amountPerPerson > 0 {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("개인당 금액:")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text("\(amountPerPerson.formatted())원")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                    
                                    if remainder > 0 {
                                        Text("나머지 \(remainder)원은 신한은행이 부담합니다")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        
                        // 친구편집 섹션
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("친구편집")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("\(participantCount)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                            }
                            
                            // 선택된 연락처 목록
                            VStack(spacing: 10) {
                                ForEach(selectedContacts, id: \.id) { contact in
                                    HStack(spacing: 15) {
                                        // 프로필 이미지
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Group {
                                                    if contact.id == "me" {
                                                        Image(systemName: "person.fill")
                                                            .foregroundColor(.gray)
                                                    } else {
                                                        Text(String(contact.name.prefix(1)))
                                                            .font(.headline)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack {
                                                if contact.id == "me" {
                                                    Image(systemName: "house.fill")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                                Text(contact.name)
                                                    .font(.headline)
                                                    .fontWeight(.medium)
                                            }
                                            
                                            if contact.phoneNumber != "나" {
                                                Text(contact.phoneNumber)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            removeContact(contact.id)
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        
                        // 키패드용 여백
                        Color.clear.frame(height: 120)
                    }
                }
                .background(Color.gray.opacity(0.05))
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .overlay(
                // 하단 버튼 완전 바닥 고정
                VStack {
                    Spacer()
                    
                    Button(action: {
                        if !totalAmount.isEmpty {
                            showConfirmationSheet = true  // 팝업 띄우기
                        }
                    }) {
                        Text(totalAmount.isEmpty ? "금액을 입력해 주세요" : "정산 요청하기")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(totalAmount.isEmpty ? Color.gray : Color.blue)
                            )
                    }
                    .disabled(totalAmount.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .ignoresSafeArea(.keyboard)
                .ignoresSafeArea(.all, edges: .bottom)
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showConfirmationSheet) {
            ConfirmationSheetView(
                totalAmount: displayAmount,
                participants: selectedContacts,
                amountPerPerson: amountPerPerson,
                onConfirm: {
                    showConfirmationSheet = false
                    showMessageComposer = true
                },
                onCancel: {
                    showConfirmationSheet = false
                }
            )
            .presentationDetents([.medium]) // 중간 크기 팝업
        }
        .sheet(isPresented: $showMessageComposer) {
            MessageComposeView(
                recipients: getRecipientPhoneNumbers(),
                messageBody: generateMessageBody(),
                onResult: { result in
                    showMessageComposer = false
                    handleMessageResult(result)
                }
            )
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func getRecipientPhoneNumbers() -> [String] {
        return selectedContacts
            .filter { $0.id != "me" }
            .map { $0.phoneNumber }
    }
    
    private func generateMessageBody() -> String {
        let senderName = contactService.myContact?.name ?? "정산대장"
        return """
        👤 \(senderName)님이 정산 요청을 보냈어요
        👥 총 \(participantCount)명이 참여합니다
        💰 총 금액: \(displayAmount)원
        🧾 개인 부담: \(amountPerPerson.formatted())원
        🔗 https://sol-settle.vercel.app/?amount=\(amountPerPerson)&sender=\(senderName)
        """
    }
    
    private func handleMessageResult(_ result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("📱 메시지 발송 취소됨")
        case .sent:
            print("✅ 메시지 발송 성공!")
        case .failed:
            print("❌ 메시지 발송 실패")
        @unknown default:
            print("❓ 알 수 없는 결과")
        }
    }
    
    private func sendSettlementRequest() {
        print("💰 총 금액: \(totalAmount)원")
        print("👥 참여자 수: \(participantCount)명 (나 포함)")
        print("💵 개인당 금액: \(amountPerPerson)원")
        
        if remainder > 0 {
            print("🏦 나머지 \(remainder)원은 신한은행이 부담")
        }
        
        print("📞 SMS 발송 대상:")
        let smsTargets = selectedContacts.filter { $0.id != "me" }
        
        for contact in smsTargets {
            print("  - \(contact.name): \(contact.phoneNumber)")
            let message = """
            👤 조윤서님이 정산 요청을 보냈어요
            💰 총 금액: \(displayAmount)원
            🧾 개인 부담: \(amountPerPerson.formatted())원
            🔗 solsettle://payment?amount=\(amountPerPerson)&sender=조윤서
            """
            print("SMS 내용: \(message)")
        }
        
        print("✅ \(smsTargets.count)명에게 정산 요청 발송 완료!")
    }
}

// 팝업 시트 뷰 (별도 struct로 분리)
struct ConfirmationSheetView: View {
    let totalAmount: String
    let participants: [Contact]
    let amountPerPerson: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 상단 제목
            VStack(spacing: 8) {
                Text("최종확인")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("총 \(totalAmount)(1차)")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            Divider()
            
            // 참여자 목록
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("친구")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(participants.count)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                
                // 참여자 리스트
                ForEach(participants, id: \.id) { contact in
                    HStack(spacing: 15) {
                        // 프로필 이미지
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Group {
                                    if contact.id == "me" {
                                        Image(systemName: "house.fill")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    } else {
                                        Text(String(contact.name.prefix(1)))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.gray)
                                    }
                                }
                            )
                        
                        Text(contact.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(amountPerPerson.formatted())원")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // 하단 버튼
            Button(action: onConfirm) {
                Text("요청하기")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

// MessageComposeView - UIViewControllerRepresentable
struct MessageComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let messageBody: String
    let onResult: (MessageComposeResult) -> Void
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = context.coordinator
        messageVC.recipients = recipients
        messageVC.body = messageBody
        return messageVC
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // 업데이트 불필요
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: MessageComposeView
        
        init(_ parent: MessageComposeView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.onResult(result)
        }
    }
}

#Preview {
    SettlementView(initialContacts: [
        Contact(id: "me", name: "조윤서", phoneNumber: "나"),
        Contact(id: "1", name: "아빠", phoneNumber: "010-1234-5678")
    ])
}
