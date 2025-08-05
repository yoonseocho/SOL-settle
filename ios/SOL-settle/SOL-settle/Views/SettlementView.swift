import SwiftUI
import MessageUI
import UserNotifications

struct SettlementData {
    let totalAmount: Int
    let amountPerPerson: Int
    let senderName: String
    let participants: [Contact]
    let settlementId: String = UUID().uuidString
}

// MARK: - SOL 사용자 확인 서비스 (테스트용)
class SOLUserCheckService: ObservableObject {
    
    // 테스트용: 특정 번호들을 SOL 사용자로 설정
    private let solUsers = [
        "010-6319-6321"
    ]
    
    func checkSOLUsers(phoneNumbers: [String]) -> [String: Bool] {
        var result: [String: Bool] = [:]
        
        for phoneNumber in phoneNumbers {
            // 실제로는 서버 API 호출, 지금은 테스트용 하드코딩
            result[phoneNumber] = solUsers.contains(phoneNumber)
        }
        
        print("🔍 SOL 사용자 확인 결과:")
        for (phone, isSOL) in result {
            print("  \(phone): \(isSOL ? "SOL 사용자 ✅" : "일반 사용자 📱")")
        }
        
        return result
    }
    
    func sendSOLPushNotification(to phoneNumbers: [String], settlementData: SettlementData) {
        for phoneNumber in phoneNumbers {
            createLocalPushNotification(phoneNumber: phoneNumber, data: settlementData)
        }
        print("🔔 SOL 푸시 알림 \(phoneNumbers.count)명에게 전송 완료")
    }
    
    private func createLocalPushNotification(phoneNumber: String, data: SettlementData) {
        // 로컬 푸시 알림 생성 (실제로는 서버에서 해당 사용자에게 푸시)
        let content = UNMutableNotificationContent()
        content.title = "💰 SOL 정산 요청"
        content.body = "\(data.senderName)님이 \(data.amountPerPerson.formatted())원 정산을 요청했습니다"
        content.sound = .default
        
        content.userInfo = [
            "type": "sol_settlement",
            "amount": data.amountPerPerson,
            "sender": data.senderName,
            "phoneNumber": phoneNumber
        ]
        
        // 액션 버튼 추가
        let payAction = UNNotificationAction(
            identifier: "sol_pay_now",
            title: "SOL에서 송금하기",
            options: [.foreground]
        )
        
        let laterAction = UNNotificationAction(
            identifier: "sol_later",
            title: "나중에",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "sol_settlement",
            actions: [payAction, laterAction],
            intentIdentifiers: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "sol_settlement"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 푸시 알림 생성 실패: \(error)")
            } else {
                print("✅ \(phoneNumber)에게 SOL 푸시 알림 생성 성공")
            }
        }
    }
}

struct SettlementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedContacts: [Contact]
    @StateObject private var contactService = ContactService()
    @StateObject private var solUserService = SOLUserCheckService()
    
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
                                            
                                            // SOL 사용자 뱃지 표시 추가!
                                            if contact.id != "me" && solUserService.checkSOLUsers(phoneNumbers: [contact.phoneNumber])[contact.phoneNumber] == true {
                                                Text("SOL")
                                                    .font(.caption2)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.blue)
                                                    .cornerRadius(8)
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
                    // 기존 SMS 방식 대신 SOL 사용자 확인 후 분기 처리
                    sendSmartSettlementRequest()
                },
                onCancel: {
                    showConfirmationSheet = false
                }
            )
            .presentationDetents([.medium]) // 중간 크기 팝업
        }
        .sheet(isPresented: $showMessageComposer) {
            MessageComposeView(
                recipients: selectedContacts
                    .filter { $0.id != "me" }
                    .filter { contact in
                        let solCheck = solUserService.checkSOLUsers(phoneNumbers: [contact.phoneNumber])
                        return solCheck[contact.phoneNumber] != true
                    }
                    .map { $0.phoneNumber },
                messageBody: generateMessageBody(),
                onResult: { result in
                    showMessageComposer = false
                    handleMessageResult(result)
                }
            )
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    private func sendSmartSettlementRequest() {
        let settlementData = SettlementData(
            totalAmount: Int(totalAmount) ?? 0,
            amountPerPerson: amountPerPerson,
            senderName: contactService.myContact?.name ?? "사용자",
            participants: selectedContacts
        )
        
        // 나를 제외한 연락처들의 전화번호 추출
        let phoneNumbers = selectedContacts
            .filter { $0.id != "me" }
            .map { $0.phoneNumber }
        
        // SOL 사용자 여부 확인
        let solUserCheck = solUserService.checkSOLUsers(phoneNumbers: phoneNumbers)
        
        // SOL 사용자와 일반 사용자 분리
        var solUsers: [String] = []
        var regularUsers: [String] = []
        
        for (phoneNumber, isSOLUser) in solUserCheck {
            if isSOLUser {
                solUsers.append(phoneNumber)
            } else {
                regularUsers.append(phoneNumber)
            }
        }
        
        print("📊 정산 요청 분기 결과:")
        print("  SOL 사용자: \(solUsers.count)명 - 푸시 알림 전송")
        print("  일반 사용자: \(regularUsers.count)명 - SMS 전송")
        
        // 1. SOL 사용자들에게 푸시 알림 전송
        if !solUsers.isEmpty {
            solUserService.sendSOLPushNotification(to: solUsers, settlementData: settlementData)
        }
        
        // 2. 일반 사용자들에게 SMS 전송
        if !regularUsers.isEmpty {
            sendSMSToRegularUsers(phoneNumbers: regularUsers, settlementData: settlementData)
        }
        
        // 결과 표시
        showSettlementResult(solCount: solUsers.count, smsCount: regularUsers.count)
    }
    
    private func sendSMSToRegularUsers(phoneNumbers: [String], settlementData: SettlementData) {
        DispatchQueue.main.async {
            self.showMessageComposer = true
        }
    }
    
    private func showSettlementResult(solCount: Int, smsCount: Int) {
        let senderName = contactService.myContact?.name ?? "조윤서"
        let resultMessage = """
        ✅ 정산 요청이 완료되었습니다!
        
        👤 요청자: \(senderName)
        💰 개인 부담금: \(amountPerPerson.formatted())원
        👥 총 \(participantCount)명 참여
        
        📱 SOL앱 알림: \(solCount)명
        💬 문자 발송: \(smsCount)명
        """
        
        print(resultMessage)
        
        // 로컬 알림으로 결과 표시
        let content = UNMutableNotificationContent()
        content.title = "💰 정산 요청"
        content.body = "\(contactService.myContact?.name ?? "조윤서")님이 \(amountPerPerson.formatted())원 정산을 요청했습니다"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "settlement_complete",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ 푸시 알림 권한 허용됨")
                } else {
                    print("❌ 푸시 알림 권한 거부됨")
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func getRecipientPhoneNumbers() -> [String] {
        let allPhoneNumbers = selectedContacts
            .filter { $0.id != "me" }
            .map { $0.phoneNumber }
        
        // SOL 사용자 확인해서 일반 사용자만 반환
        let solUserCheck = solUserService.checkSOLUsers(phoneNumbers: allPhoneNumbers)
        
        return allPhoneNumbers.filter { phoneNumber in
            solUserCheck[phoneNumber] != true  // SOL 사용자가 아닌 경우만
        }
    }
    
    private func generateMessageBody() -> String {
        let senderName = contactService.myContact?.name ?? "조윤서"
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
        Contact(id: "1", name: "조세현", phoneNumber: "010-6319-6321"), // SOL 사용자
        Contact(id: "2", name: "임채희", phoneNumber: "010-8652-1471")  // 일반 사용자
    ])
}
