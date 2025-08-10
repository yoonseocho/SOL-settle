# 신한SOL 정산 서비스

> FAISS 기반 AI 추천과 계좌 간 직접송금으로 더치페이의 새로운 기준을 제시하는 신한SOL 통합 간편 정산 서비스

## 🎯 왜 만들었나요?

### 기존 정산 서비스의 Pain Points
- **충전식 중간 플랫폼**: 카카오페이, 토스페이 등은 계좌 ↔ 페이머니 ↔ 계좌 형태로 중간 단계를 거쳐야 함
- **주거래 은행 외 자금 분산**: 자주 사용하지 않는 플랫폼에 돈이 묶여있게 됨
- **거래내역 파편화**: "카카오페이 출금 10,000원" 식으로 표시되어 실제 용도를 파악하기 어려움
- **수동 참여자 선택**: 매번 정산할 때마다 참여자를 일일이 선택해야 하는 번거로움

### 우리의 해결책
✅ **계좌 to 계좌 직접 송금** - 중간 플랫폼 없이 바로 송금  
✅ **FAISS 기반 AI 추천** - 과거 정산 패턴을 학습하여 참여자 자동 추천  
✅ **주거래 은행 통합 관리** - 모든 정산 내역을 신한SOL에서 일괄 확인  
✅ **스마트 거래내역** - "조윤서 5,690원 (식비)" 형태로 상세하게 표시  
✅ **자동 가계부 연동** - 송금 완료 후 카테고리 선택으로 즉시 가계부 반영

## 🧠 FAISS 기반 AI 정산 참여자 추천

### 핵심 기술 스택
- **FAISS (Facebook AI Similarity Search)**: 벡터 유사도 검색 엔진
- **TF-IDF**: 장소명 텍스트 벡터화
- **scikit-learn**: 수치 특성 정규화 및 전처리

### 추천 알고리즘 동작 과정

1. **특성 벡터화**
   ```python
   # 장소명 → TF-IDF 벡터
   place_features = vectorizer.fit_transform(df['place']).toarray()
   
   # 시간, 금액 → 정규화된 수치 벡터
   numeric_features = scaler.fit_transform(df[['hour', 'amount']])
   
   # 통합 특성 벡터 생성
   feature_matrix = np.hstack([place_features, numeric_features])
   ```

2. **FAISS 인덱스 구축**
   ```python
   # L2 거리 기반 인덱스 생성
   index = faiss.IndexFlatL2(dimension)
   index.add(features.astype('float32'))
   ```

3. **유사도 검색 및 추천**
   ```python
   # 현재 정산과 유사한 과거 거래 검색
   distances, indices = index.search(query_vector, k=3)
   
   # 참여자별 가중점수 계산
   similarity_score = 1 / (1 + distance)
   ```

### 추천 결과 예시
```json
{
  "평촌쪽갈비_19_70000": {
    "recommended_participants": ["홍길동", "김영희", "최민수", "박지현"],
    "confidence_scores": {
      "홍길동": 2.72,
      "김영희": 2.72,
      "최민수": 2.72,
      "박지현": 1.77
    },
    "explanation": "과거 '평촌쪽갈비' 정산 기록을 기반으로 생성되었습니다."
  }
}
```

## 🌟 주요 특징

### 1. 🎯 똑똑한 정산 요청
- **AI 참여자 추천**: 과거 정산 패턴을 학습하여 최적의 참여자 자동 제안
- **SOL 사용자 자동 감지**: 연락처에서 SOL 사용자와 일반 사용자를 자동으로 구분
- **맞춤형 전송**: SOL 사용자에게는 푸시 알림, 일반 사용자에게는 SMS 링크 전송
- **1/N 자동 계산**: 총 금액 입력하면 인원수에 맞춰 자동으로 개인 부담금 계산

### 2. 📱 원클릭 정산 (정산 받는 사람)
```
정산 요청 수신 → 링크/알림 클릭 → 은행앱 선택 → 금액 자동입력 → 송금 완료
```
- **딥링크 연동**: 송금 금액과 받는 사람 정보가 자동으로 입력됨
- **다양한 은행 지원**: 토스, 카카오뱅크, KB, 하나, 우리, 농협 등 주요 은행 연동
- **SOL 우대**: SOL 사용자는 푸시 알림으로 더욱 간편하게

### 3. 📊 스마트 가계부 연동
- **카테고리 자동 분류**: 송금 완료 후 식비, 교통비, 쇼핑 등 카테고리 선택
- **명확한 거래내역**: "홍길동 25,000원 (식비)" 형태로 누구에게, 무엇 때문에 송금했는지 명확히 표시
- **주거래 은행 통합 관리**: 신한SOL에서 모든 정산 내역을 한 번에 확인

### 4. 🔐 금융 보안 기준
- **신한은행 보안 인프라**: 기존 신한SOL의 보안 시스템 활용
- **실제 계좌 연동**: 가상 계좌나 중간 플랫폼 없이 실제 은행 계좌 간 직접 송금

## 👥 사용자별 시나리오

### 1️⃣ 정산 요청자 (SOL 사용자)
> 신한SOL 앱에서 정산 요청하는 사람

**플로우 1: 새 정산 요청**
```
신한SOL 메인 → 정산하기 → AI 추천 확인 → 연락처 선택 → 금액 입력 → 요청 전송
```

**플로우 2: 거래내역 기반 정산**
```
신한SOL 거래내역 → 정산하기 버튼 → AI 추천 확인 → 연락처 선택 → 요청 전송
```

**혜택:**
- AI가 추천한 참여자로 빠른 선택
- 거래내역에서 바로 정산 시 금액 자동 입력
- SOL 사용자 자동 감지로 최적화된 전송
- 1/N 자동 계산으로 개인 부담금 즉시 확인

### 2️⃣ 정산 대상자 - 타행 사용자
> 정산 요청을 받은 다른 은행 사용자

**플로우:**
```
SMS 수신 → 링크 클릭 → 은행앱 선택 → 자동 금액 입력 → 송금 완료
```

**혜택:**
- SOL 앱 설치 불필요
- 본인이 사용하는 은행앱에서 바로 송금
- 정산 금액이 자동으로 입력되어 편리함

### 3️⃣ 정산 대상자 - SOL 사용자
> 정산 요청을 받은 SOL 사용자

**플로우:**
```
푸시 알림 수신 → 알림 탭 → SOL에서 자동 송금 화면 → 송금 완료 → 카테고리 선택
```

**혜택:**
- 푸시 알림으로 즉시 확인
- SOL 앱에서 바로 송금
- 송금 후 카테고리 선택으로 자동 가계부 입력
- 거래내역에 "홍길동 25,000원 (식비)" 형태로 상세 표시

## 🛠 사용한 오픈소스

### Machine Learning
- **FAISS**: 벡터 유사도 검색 및 AI 추천 엔진
- **pandas**: 정산 데이터 처리 및 분석
- **numpy**: 수치 연산 및 벡터 계산
- **scikit-learn**: TF-IDF 벡터화 및 데이터 전처리

### iOS Third-party Libraries
- **URLNavigator**: URL 기반 화면 라우팅 및 딥링크 처리
- **SwiftMessages**: 앱 내 알림 UI 및 토스트 메시지
- **SnapKit**: Auto Layout 코드 작성 간소화
- **SwiftyUserDefaults**: 사용자 설정 및 계좌 정보 저장

## 🚀 확장 가능성

### 기술적 확장성
- **새로운 은행 추가**: 현재 6개 은행 지원에서 추가 은행 API 연동을 통한 서비스 확대
- **추천 알고리즘 고도화**: 현재 장소, 시간, 금액 기반에서 요일, 참여자 관계, 빈도 등 추가 특성 반영

### 서비스 확장
- **거래내역 연동**: 신한카드 결제 내역과 자동 연동하여 즉시 정산 요청 생성
- **신한 통합 가계부 연동**: 현재 카테고리 선택 후 거래내역 표시에서 신한SOL 가계부 기능과의 완전 통합
- **반복 정산 자동화**: 정기 모임, 월세 등 주기적 정산의 자동 스케줄링 및 알림

## 📁 프로젝트 구조

```
SOL-settle/
├── ios/                          # iOS 앱
│   ├── Models/                   # 데이터 모델
│   ├── Views/                    # SwiftUI 뷰
│   ├── Services/                 # 비즈니스 로직
│   └── Resources/
├── ml/                           # 머신러닝 모델
│   ├── faiss_train_and_predict.py
│   ├── recommendations.json
│   └── transactions.csv
├── web/                          # 웹 버전 (타행 사용자용)
│   ├── index.html
│   ├── style.css
│   └── script.js
└── README.md
```

## 🎬 데모 영상

### 📱 정산 요청자 시연1
> 신한SOL에서 직접 친구들에게 정산 요청하고 입금 확인하는 과정
<div align="center">
 <img src="https://github.com/user-attachments/assets/661024de-72c4-4095-98be-478549052b3c" width="300">
 <img src="https://github.com/user-attachments/assets/146229ae-9d7d-460b-b78a-9c86743ff6b4" width="300">
</div>

### 📱 정산 요청자 시연2
> 신한SOL에서 AI 추천을 받아 친구들에게 정산 요청하는 과정
<div align="center">
 <img src="https://github.com/user-attachments/assets/40fe47e1-5635-4dc7-82d5-dbbdcfa2f120" width="300">
</div>

### 📨 타행 사용자 시연  
> SMS 링크를 통해 타행 앱에서 송금하는 과정
<div align="center">
 <img src="https://github.com/user-attachments/assets/a2d87efd-4252-45cd-95cf-10416cab94c6" width="300">
</div>

### 🔔 SOL 사용자 시연
> 푸시 알림을 받고 SOL에서 바로 송금하는 과정
<div align="center">
 <img src="https://github.com/user-attachments/assets/275cb185-bc80-4e33-a2ec-a1241803b595" width="300">
</div>

## 🚀 설치 및 실행

### 요구 사항
- iOS 16.2+
- Xcode 15.4+
- Swift 5.10+

### iOS 앱 설치
```bash
git clone https://github.com/yoonseocho/SOL-settle.git
cd SOL-settle
pod install
open SOL-settle.xcworkspace
```

---

⚠️ **주의사항**: 이 프로젝트는 신한SOL 서비스의 시뮬레이션 버전이며, 실제 금융 거래는 이루어지지 않습니다.

💡 **문의사항**: 프로젝트에 대한 문의나 제안은 Issues를 통해 남겨주세요!
