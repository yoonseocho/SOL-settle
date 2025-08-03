import Foundation

struct Contact: Identifiable, Hashable {
    let id: String
    let name: String
    let phoneNumber: String
    
    init(id: String = UUID().uuidString, name: String, phoneNumber: String) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
    }
}
