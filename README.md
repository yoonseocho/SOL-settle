# 신한SOL 정산 서비스 (시뮬레이션)

친구들과의 더치페이를 쉽고 빠르게 할 수 있는 신한SOL 앱 통합 간편 정산 서비스

## 📱 프로젝트 개요

신한SOL 앱에 통합된 간편 정산 서비스로, 친구들과의 더치페이를 쉽고 빠르게 처리할 수 있는 iOS 앱입니다. 
기존 신한SOL 앱의 보안 제약으로 인해 별도의 시뮬레이션 앱으로 구현합니다.

## 🎯 주요 기능

### 💰 간편 정산 요청
- 연락처 기반 친구 선택
- 총 금액 및 개별 정산 금액 입력
- 자동 정산 요청 문자 발송

### 🔗 정적 딥링크 정산
- 정산 요청 문자 수신 시 원클릭 정산
- 은행 앱 선택 후 정산 금액 자동 입력
- 즉시 송금 완료

## 👥 사용자 시나리오

### 1️⃣ 정산 요청자 (정산하는 사람)
```
신한SOL 메인화면 → 정산하기 버튼 클릭 → 연락처 선택 → 금액 입력 → 정산 요청 전송
```

**상세 플로우:**
1. 신한SOL 앱 메인화면에서 '정산하기' 버튼 선택
2. 휴대폰 연락처로 자동 연결
3. 정산할 친구들 선택 (다중 선택 가능)
4. 총 금액 및 개별 정산 금액 입력
5. 정산 요청 문자 자동 발송

### 2️⃣ 정산 대상자 (정산 요청 받는 사람)
```
정산 요청 문자 수신 → 링크 클릭 → 은행 선택 → 자동 송금
```

**상세 플로우:**
1. 정산 요청 문자 수신
```
👤 윤서님이 정산 요청을 보냈어요
💰 [총 결제 금액] 50,000원
🧾 [당신이 정산할 금액] 25,000원
👇 지금 정산하러 가기
🔗 solsettle://settlement?amount=25000&account=3333021234567
```
2. 링크 클릭으로 정산 페이지 접속
3. 원하는 은행 앱 선택
4. **핵심 기능**: 선택한 은행 앱에 정산 금액이 자동으로 입력됨
5. 확인 버튼 누르면 바로 송금완료

## 🛠 기술 스택

### 📱 iOS 개발
- **Swift** - iOS 네이티브 개발
- **UIKit** - UI 프레임워크
- **SwiftUI** - 모던 UI 구현

## 🛠 사용한 오픈소스

### Core iOS Frameworks
- **Swift** - iOS 네이티브 개발
- **UIKit** - UI 프레임워크  
- **SwiftUI** - 모던 UI 구현
- **Contacts Framework** - 연락처 접근
- **MessageUI Framework** - SMS 발송

### Third-party Libraries
- **URLNavigator** - URL 기반 화면 라우팅
- **SwiftMessages** - 앱 내 알림 UI
- **SnapKit** - Auto Layout 라이브러리
- **Then** - Swift 코드 간소화
- **SwiftyUserDefaults** - 사용자 설정 및 계좌 정보 저장

## 📁 프로젝트 구조

```
SOL-settle/
├── ios/                          # iOS 앱 (정산 요청자 + 정산 받는 사람)
│   ├── SOL-settle/
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   ├── Info.plist           # URL Scheme: solsettle://
│   │   │
│   │   ├── Models/
│   │   │   ├── Contact.swift
│   │   │   └── Settlement.swift
│   │   │
│   │   ├── ViewControllers/
│   │   │   ├── MainViewController.swift        # 신한SOL 메인화면
│   │   │   ├── ContactSelectionViewController.swift  # 연락처 선택
│   │   │   ├── SettlementViewController.swift  # 금액 입력 & 정산 요청
│   │   │   └── PaymentViewController.swift     # 정산 받는 사람용 송금 화면
│   │   │
│   │   ├── Services/
│   │   │   ├── ContactService.swift    # 연락처 가져오기
│   │   │   ├── MessageService.swift    # SMS 발송
│   │   │   └── DeepLinkService.swift   # URL Scheme 처리
│   │   │
│   │   └── Resources/
│   │       └── Assets.xcassets/
│   │           └── shinhan_blue.colorset
│   │
│   ├── SOL-settle.xcodeproj
│   └── Podfile
│
├── web/                          # 앱 미설치자용 웹페이지
│   ├── index.html               # 앱 다운로드 안내 페이지
│   ├── style.css               # 신한SOL 스타일
│   └── script.js               # 앱스토어 리디렉션
│
├── README.md
└── .gitignore
```

## 🚀 설치 및 실행

### 요구 사항
- iOS 16.2+
- Xcode 15.4+
- Swift 5.10+

### 설치 방법
1. 저장소 클론
```bash
git clone https://github.com/yoonseocho/SOL-settle.git
cd SOL-settle
```

2. CocoaPods 의존성 설치
```bash
pod install
```

3. Xcode에서 `.xcworkspace` 파일 열기
```bash
open SOL-settle.xcworkspace
```

## 🔧 설정
`Info.plist`에 Custom URL Scheme 추가:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.shinhan.sol.settlement</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>solsettle</string>
        </array>
    </dict>
</array>
```
---

⚠️ **주의사항**: 이 프로젝트는 신한SOL 서비스의 시뮬레이션 버전이며, 실제 금융 거래는 이루어지지 않습니다.
