import Contacts
import Foundation
import UIKit

class ContactService: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var myContact: Contact? = nil
    @Published var isLoading = false
    @Published var permissionDenied = false
    
    private let contactStore = CNContactStore()
    
    func requestContactPermission() {
        contactStore.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.fetchMyContact()
                    self.fetchContacts()
                } else {
                    self.permissionDenied = true
                    print("연락처 권한이 거부되었습니다")
                }
            }
        }
    }
    
    private func fetchMyContact() {
        // 방법 1: 연락처에서 "내 카드" 찾기
        if let meContact = findMeCardFromContacts() {
            DispatchQueue.main.async {
                self.myContact = meContact
                print("✅ 연락처에서 내 정보 찾음: \(meContact.name)")
            }
            return
        }
        
        // 방법 2: 기기 이름에서 추출
        let deviceName = UIDevice.current.name
        print("🔍 실제 기기 이름: '\(deviceName)'")
        
        var userName = extractUserNameFromDevice(deviceName)
        print("🔍 추출된 사용자 이름: '\(userName)'")
        
        // 방법 3: 실패시 기본값
        if userName.isEmpty || userName == "iPhone" || userName == "iPad" {
            userName = "나"
        }
        
        DispatchQueue.main.async {
            self.myContact = Contact(
                id: "me",
                name: userName,
                phoneNumber: "나"
            )
            print("✅ 최종 내 이름: \(self.myContact?.name ?? "알 수 없음")")
        }
    }
    
    // 연락처에서 "내 카드" 찾기 (다른 방법 시도)
    private func findMeCardFromContacts() -> Contact? {
        // iOS에서 직접적인 "내 카드" 접근이 제한되어 있음
        // 기기 이름을 이용한 추출 방식을 우선 사용
        return nil
    }
    
    // 기기 이름에서 사용자 이름 추출
    private func extractUserNameFromDevice(_ deviceName: String) -> String {
        var userName = deviceName
        
        // 한국어 패턴들
        let koreanPatterns = [
            "의 iPhone",
            "의 iPad",
            "의 iPod",
            "의 Mac"
        ]
        
        // 영어 패턴들
        let englishPatterns = [
            "'s iPhone",
            "'s iPad",
            "'s iPod",
            "'s Mac"
        ]
        
        // 한국어 패턴 확인 (우선순위)
        for pattern in koreanPatterns {
            if userName.hasSuffix(pattern) {
                userName = String(userName.dropLast(pattern.count))
                break
            }
        }
        
        // 영어 패턴 확인
        if userName == deviceName { // 한국어 패턴이 매치되지 않았다면
            for pattern in englishPatterns {
                if userName.hasSuffix(pattern) {
                    userName = String(userName.dropLast(pattern.count))
                    break
                }
            }
        }
        
        return userName.trimmingCharacters(in: .whitespaces)
    }
    
    private func fetchContacts() {
        isLoading = true
        
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey
        ] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        DispatchQueue.global(qos: .userInitiated).async {
            var fetchedContacts: [Contact] = []
            
            do {
                try self.contactStore.enumerateContacts(with: request) { cnContact, _ in
                    // 전화번호가 있는 연락처만 가져오기
                    if !cnContact.phoneNumbers.isEmpty {
                        let fullName = "\(cnContact.familyName)\(cnContact.givenName)".trimmingCharacters(in: .whitespaces)
                        let phoneNumber = cnContact.phoneNumbers.first?.value.stringValue ?? ""
                        
                        if !fullName.isEmpty && !phoneNumber.isEmpty {
                            let contact = Contact(
                                name: fullName,
                                phoneNumber: phoneNumber
                            )
                            fetchedContacts.append(contact)
                        }
                    }
                }
                
                // 이름순으로 정렬
                fetchedContacts.sort { $0.name < $1.name }
                
                DispatchQueue.main.async {
                    self.contacts = fetchedContacts
                    self.isLoading = false
                    print("연락처 \(fetchedContacts.count)개 로드 완료")
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("연락처 가져오기 실패: \(error)")
                }
            }
        }
    }
    
    func checkContactPermission() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized:
            fetchMyContact()
            fetchContacts()
        case .denied, .restricted:
            permissionDenied = true
        case .notDetermined:
            requestContactPermission()
        @unknown default:
            permissionDenied = true
        }
    }
}
