import pandas as pd
import numpy as np
import faiss
import json
from datetime import datetime
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import StandardScaler

class SettlementRecommendationEngine:
    def __init__(self, csv_path='transactions.csv'):
        self.df = pd.read_csv(csv_path)
        self.vectorizer = TfidfVectorizer(max_features=100)
        self.scaler = StandardScaler()
        self.index = None
        self.feature_matrix = None
        
    def preprocess_data(self):
        """거래 데이터를 벡터로 변환"""
        # 시간대 추출 (19시 -> 19)
        self.df['hour'] = pd.to_datetime(self.df['datetime']).dt.hour
        
        # 장소명 벡터화
        place_features = self.vectorizer.fit_transform(self.df['place']).toarray()
        
        # 수치 특성 정규화 (시간, 금액)
        numeric_features = self.scaler.fit_transform(self.df[['hour', 'amount']])
        
        # 모든 특성 결합
        self.feature_matrix = np.hstack([place_features, numeric_features])
        
        print(f"Feature matrix shape: {self.feature_matrix.shape}")
        return self.feature_matrix
    
    def build_faiss_index(self):
        """FAISS 인덱스 구축"""
        features = self.preprocess_data()
        dimension = features.shape[1]
        
        # L2 거리 기반 인덱스 생성
        self.index = faiss.IndexFlatL2(dimension)
        self.index.add(features.astype('float32'))
        
        print(f"FAISS index built with {self.index.ntotal} vectors")
        
    def get_recommendations(self, place, hour, amount, k=3):
        """유사한 거래 찾아서 참여자 추천"""
        if self.index is None:
            self.build_faiss_index()
        
        # 쿼리 벡터 생성
        query_place = self.vectorizer.transform([place]).toarray()
        query_numeric = self.scaler.transform([[hour, amount]])
        query_vector = np.hstack([query_place, query_numeric]).astype('float32')
        
        # 유사한 거래 검색
        distances, indices = self.index.search(query_vector, k)
        
        # 추천 결과 생성
        recommendations = []
        participant_counts = {}
        
        for i, idx in enumerate(indices[0]):
            if distances[0][i] < float('inf'):  # 유효한 결과만
                row = self.df.iloc[idx]
                participants = row['participants'].split('|')
                similarity_score = 1 / (1 + distances[0][i])  # 거리를 유사도로 변환
                
                recommendations.append({
                    'place': row['place'],
                    'datetime': row['datetime'],
                    'amount': int(row['amount']),
                    'participants': participants,
                    'similarity': float(similarity_score),
                    'distance': float(distances[0][i])
                })
                
                # 참여자별 빈도 계산
                for participant in participants:
                    participant_counts[participant] = participant_counts.get(participant, 0) + similarity_score
        
        # 가장 많이 언급된 참여자들 선별
        top_participants = sorted(participant_counts.items(), key=lambda x: x[1], reverse=True)[:4]
        
        return {
            'recommended_participants': [p[0] for p in top_participants],
            'confidence_scores': {p[0]: float(p[1]) for p in top_participants},
            'similar_transactions': recommendations,
            'explanation': f"과거 '{recommendations[0]['place']}' 정산 기록을 기반으로 생성되었습니다." if recommendations else "유사한 정산 기록이 없습니다."
        }

def generate_recommendations_json():
    """다양한 시나리오에 대한 추천 결과를 JSON으로 생성"""
    engine = SettlementRecommendationEngine()
    
    # 테스트 시나리오들
    test_scenarios = [
        {'place': '평촌쪽갈비', 'hour': 19, 'amount': 70000},
        {'place': '맥도날드 평촌점', 'hour': 20, 'amount': 30000},
        {'place': '스타벅스 범계점', 'hour': 18, 'amount': 15000},
        {'place': '교촌치킨 평촌점', 'hour': 19, 'amount': 40000},
        {'place': '김밥천국', 'hour': 19, 'amount': 20000},
    ]
    
    recommendations = {}
    
    for scenario in test_scenarios:
        key = f"{scenario['place']}_{scenario['hour']}_{scenario['amount']}"
        result = engine.get_recommendations(
            scenario['place'], 
            scenario['hour'], 
            scenario['amount']
        )
        recommendations[key] = result
        
        print(f"\n--- {scenario['place']} 추천 결과 ---")
        print(f"추천 참여자: {result['recommended_participants']}")
        print(f"설명: {result['explanation']}")
    
    # JSON 파일로 저장
    with open('recommendations.json', 'w', encoding='utf-8') as f:
        json.dump(recommendations, f, ensure_ascii=False, indent=2)
    
    print("\n✅ recommendations.json 파일이 생성되었습니다!")
    return recommendations

if __name__ == "__main__":
    print("🤖 FAISS 기반 정산 참여자 추천 엔진 시작...")
    results = generate_recommendations_json()
    print(f"✅ {len(results)}개 시나리오에 대한 추천 완료!")
