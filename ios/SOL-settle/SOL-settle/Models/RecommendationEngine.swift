import Foundation
import SwiftUI

// MARK: - 추천 결과 모델
struct ParticipantRecommendation: Codable {
    let recommendedParticipants: [String]
    let confidenceScores: [String: Double]
    let similarTransactions: [SimilarTransaction]
    let explanation: String
    
    enum CodingKeys: String, CodingKey {
        case recommendedParticipants = "recommended_participants"
        case confidenceScores = "confidence_scores"
        case similarTransactions = "similar_transactions"
        case explanation
    }
}

struct SimilarTransaction: Codable {
    let place: String
    let datetime: String
    let amount: Int
    let participants: [String]
    let similarity: Double
    let distance: Double
}

// MARK: - 추천 엔진 서비스
class RecommendationEngine: ObservableObject {
    @Published var isLoading = false
    private var recommendations: [String: ParticipantRecommendation] = [:]
    
    init() {
        loadRecommendations()
    }
    
    private func loadRecommendations() {
        guard let path = Bundle.main.path(forResource: "recommendations", ofType: "json") else {
            print("❌ recommendations.json 파일을 찾을 수 없습니다")
            return
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("❌ 파일 읽기 실패")
            return
        }
        
        // 파싱 추가
        guard let decoded = try? JSONDecoder().decode([String: ParticipantRecommendation].self, from: data) else {
            print("❌ JSON 파싱 실패")
            return
        }
        
        recommendations = decoded
        print("✅ 추천 데이터 로드 완료: \(recommendations.keys.count)개 시나리오")
    }
    
    func getRecommendedParticipants(for transaction: Transaction) -> ParticipantRecommendation? {
        // 거래 설명에서 장소 추출
        let place = extractPlace(from: transaction.description)
        let hour = Calendar.current.component(.hour, from: transaction.date)
        let amount = transaction.amount
        
        print("🔍 추천 검색 - 장소: \(place), 시간: \(hour)시, 금액: \(amount)원")
        
        return getRecommendedParticipants(place: place, hour: hour, amount: amount)
    }
    
    func getRecommendedParticipants(place: String, hour: Int, amount: Int) -> ParticipantRecommendation? {
        let key = "\(place)_\(hour)_\(amount)"
        
        // 정확히 일치하는 키 찾기
        if let exactMatch = recommendations[key] {
            print("✅ 정확한 매치 발견: \(key)")
            return exactMatch
        }
        
        // 유사한 키 찾기 (장소명 기준)
        let similarKey = recommendations.keys.first { key in
            let keyPlace = key.components(separatedBy: "_")[0]
            return place.contains(keyPlace) || keyPlace.contains(place)
        }
        
        if let similarKey = similarKey {
            print("✅ 유사한 매치 발견: \(similarKey)")
            return recommendations[similarKey]
        }
        
        // 기본 추천 (첫 번째 추천 결과 반환)
        if let defaultRecommendation = recommendations.values.first {
            print("⚠️ 기본 추천 사용")
            return defaultRecommendation
        }
        
        print("❌ 추천 결과 없음")
        return nil
    }
    
    private func extractPlace(from description: String) -> String {
        // 거래 설명에서 장소명 추출
        let placeMapping = [
            "스타벅스": "스타벅스 범계점",
            "맥도날드": "맥도날드 평촌점",
            "교촌치킨": "교촌치킨 평촌점",
            "김밥천국": "김밥천국",
            "버거킹": "버거킹 평촌점"
        ]
        
        for (keyword, fullPlace) in placeMapping {
            if description.contains(keyword) {
                return fullPlace
            }
        }
        
        // 사람 이름이면 갈비집으로 가정 (임시)
        if description.contains("조세현") || description.contains("임채희") ||
           description.contains("김민수") || description.contains("박지현") {
            return "평촌쪽갈비"
        }
        
        return description // 그대로 반환
    }
}

// MARK: - Contact 확장 (추천 시스템용)
extension Contact {
    static func fromRecommendation(_ names: [String]) -> [Contact] {
        return names.map { name in
            Contact(id: UUID().uuidString, name: name, phoneNumber: "010-0000-0000")
        }
    }
}
