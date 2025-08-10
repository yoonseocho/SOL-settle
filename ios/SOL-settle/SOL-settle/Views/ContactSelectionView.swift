import SwiftUI

struct ContactSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedContacts: Set<String> = ["me"]
    
    @StateObject private var contactService = ContactService()
    
    // 🆕 거래내역에서 전달받은 정보 (옵셔널로 변경)
    let presetAmount: Int?
    let presetDescription: String?
    
    // 🔧 생성자 수정 - @StateObject 문제 해결
    init(presetAmount: Int? = nil, presetDescription: String? = nil) {
        self.presetAmount = presetAmount
        self.presetDescription = presetDescription
    }
    
    private func getSelectedContactsList() -> [Contact] {
        var contacts: [Contact] = []
        
        if selectedContacts.contains("me") {
            contacts.append(Contact(id: "me", name: "나", phoneNumber: "나"))
        }
        
        // 선택된 AI 추천 연락처들 추가
        for contact in getAIRecommendations() {
            if selectedContacts.contains(contact.id) {
                contacts.append(contact)
            }
        }
        
        // 선택된 실제 연락처들 추가
        for contactId in selectedContacts {
            if contactId != "me" && !contactId.hasPrefix("ai_rec_"),
               let contact = contactService.contacts.first(where: { $0.id == contactId }) {
                contacts.append(contact)
            }
        }
        
        return contacts
    }
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contactService.contacts
        } else {
            return contactService.contacts.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                    
                    VStack(spacing: 2) {
                        if let presetDescription = presetDescription {
                            Text("\(presetDescription) 정산하기")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("연락처에서 선택")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("어디로 보낼까요?")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("연락처에서 선택")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // 더보기 기능
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color.white)
                
                // 스크롤 가능한 콘텐츠
                ScrollView {
                    VStack(spacing: 0) {
                        // 🆕 AI 추천 섹션
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.blue)
                                Text("🤖 AI 추천")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            // AI 추천 연락처들
                            ForEach(getAIRecommendations(), id: \.id) { contact in
                                HStack(spacing: 15) {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(String(contact.name.prefix(1)))
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Image(systemName: "brain.head.profile")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            Text(contact.name)
                                                .font(.headline)
                                                .fontWeight(.medium)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        toggleSelection(for: contact.id)
                                    }) {
                                        Circle()
                                            .stroke(selectedContacts.contains(contact.id) ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Group {
                                                    if selectedContacts.contains(contact.id) {
                                                        Circle()
                                                            .fill(Color.blue)
                                                            .frame(width: 16, height: 16)
                                                            .overlay(
                                                                Image(systemName: "checkmark")
                                                                    .font(.caption)
                                                                    .foregroundColor(.white)
                                                            )
                                                    }
                                                }
                                            )
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(20)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // 선택된 연락처 상단 표시 (잘림 방지)
                        if !selectedContacts.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    if selectedContacts.contains("me") {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(
                                                        Image(systemName: "person.fill")
                                                            .foregroundColor(.gray)
                                                    )
                                                
                                                // X 버튼
                                                Button(action: {
                                                    selectedContacts.remove("me")
                                                }) {
                                                    Circle()
                                                        .fill(Color.gray)
                                                        .frame(width: 20, height: 20)
                                                        .overlay(
                                                            Image(systemName: "xmark")
                                                                .font(.caption2)
                                                                .foregroundColor(.white)
                                                        )
                                                }
                                                .offset(x: 18, y: -18)
                                            }
                                            
                                            Text(contactService.myContact?.name ?? "나")
                                                .font(.caption)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    
                                    // 선택된 AI 추천 연락처들
                                    ForEach(getAIRecommendations().filter { selectedContacts.contains($0.id) }, id: \.id) { contact in
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.blue.opacity(0.2))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(
                                                        Text(String(contact.name.prefix(1)))
                                                            .font(.headline)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.blue)
                                                    )
                                                
                                                // X 버튼
                                                Button(action: {
                                                    selectedContacts.remove(contact.id)
                                                }) {
                                                    Circle()
                                                        .fill(Color.gray)
                                                        .frame(width: 20, height: 20)
                                                        .overlay(
                                                            Image(systemName: "xmark")
                                                                .font(.caption2)
                                                                .foregroundColor(.white)
                                                        )
                                                }
                                                .offset(x: 18, y: -18)
                                            }
                                            
                                            Text(contact.name)
                                                .font(.caption)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    
                                    // 선택된 실제 연락처들
                                    ForEach(Array(selectedContacts.filter { $0 != "me" && !$0.hasPrefix("ai_rec_") }), id: \.self) { contactId in
                                        if let contact = contactService.contacts.first(where: { $0.id == contactId }) {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 50, height: 50)
                                                        .overlay(
                                                            Text(String(contact.name.prefix(1)))
                                                                .font(.headline)
                                                                .fontWeight(.bold)
                                                                .foregroundColor(.gray)
                                                        )
                                                    
                                                    // X 버튼
                                                    Button(action: {
                                                        selectedContacts.remove(contactId)
                                                    }) {
                                                        Circle()
                                                            .fill(Color.gray)
                                                            .frame(width: 20, height: 20)
                                                            .overlay(
                                                                Image(systemName: "xmark")
                                                                    .font(.caption2)
                                                                    .foregroundColor(.white)
                                                            )
                                                    }
                                                    .offset(x: 18, y: -18)
                                                }
                                                
                                                Text(contact.name)
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                    }
                                    Spacer(minLength: 20)
                                }
                                .padding(.horizontal, 20)
                                .padding(.trailing, 20)
                                .padding(.vertical, 15)
                            }
                            .frame(height: 110)
                            .background(Color.white)
                        }
                        
                        // 검색바
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("이름 검색", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        // 연락처 헤더 (좌측 정렬)
                        HStack {
                            Text("연락처 (\(filteredContacts.count + 1))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Button(action: {
                                // 펼치기/접기
                            }) {
                                Image(systemName: "chevron.up")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        
                        // 연락처 리스트
                        LazyVStack(spacing: 0) {
                            ContactRow(
                                contact: contactService.myContact ?? Contact(id: "me", name: "나", phoneNumber: "나"),
                                isSelected: selectedContacts.contains("me")
                            ) {
                                toggleSelection(for: "me")
                            }
                            
                            // 구분선
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // 실제 연락처들
                            ForEach(filteredContacts, id: \.id) { contact in
                                ContactRow(
                                    contact: contact,
                                    isSelected: selectedContacts.contains(contact.id)
                                ) {
                                    toggleSelection(for: contact.id)
                                }
                            }
                        }
                        .background(Color.white)
                        
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
                    
                    NavigationLink(destination: SettlementView(initialContacts: getSelectedContactsList(), presetAmount: presetAmount)) {
                        Text("1/N 정산하기")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(selectedContacts.isEmpty ? Color.gray : Color.blue)
                            )
                    }
                    .disabled(selectedContacts.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .ignoresSafeArea(.keyboard)
                .ignoresSafeArea(.all, edges: .bottom)
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🎯 ContactSelectionView 나타남!")
            contactService.checkContactPermission()
            // AI 추천 연락처들을 기본 선택
            for contact in getAIRecommendations() {
                selectedContacts.insert(contact.id)
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func toggleSelection(for contactId: String) {
        if selectedContacts.contains(contactId) {
            selectedContacts.remove(contactId)
        } else {
            selectedContacts.insert(contactId)
        }
    }
    
    private func getAIRecommendations() -> [Contact] {
        // AI 추천 연락처 (하드코딩)
        return [
            Contact(id: "ai_rec_1", name: "조세현", phoneNumber: "010-6319-6321"),
            Contact(id: "ai_rec_2", name: "임채희", phoneNumber: "010-8652-1471"),
            Contact(id: "ai_rec_3", name: "김민수", phoneNumber: "010-1234-5678")
        ]
    }
}

// 연락처 행 컴포넌트
struct ContactRow: View {
    let contact: Contact
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // 프로필 이미지
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 45, height: 45)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                
                Text(contact.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Spacer()
                
                // 선택 체크박스
                Circle()
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Group {
                            if isSelected {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContactSelectionView()
}
