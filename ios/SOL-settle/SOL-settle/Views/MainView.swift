import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단 네비게이션 바
                HStack {
                    // 쉬운 홈 버튼
                    HStack(spacing: 5) {
                        Text("쉬운")
                            .foregroundColor(.white)
                        Text("홈")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                    )
                    .font(.caption)
                    
                    Spacer()
                    
                    HStack(spacing: 25) {
                        VStack(spacing: 2) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                            Text("검색")
                                .font(.caption2)
                        }
                        
                        VStack(spacing: 2) {
                            Image(systemName: "message")
                                .font(.title3)
                            Text("챗봇")
                                .font(.caption2)
                        }
                        
                        VStack(spacing: 2) {
                            Image(systemName: "person")
                                .font(.title3)
                            Text("마이")
                                .font(.caption2)
                        }
                    }
                    .foregroundColor(.black)
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 15)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 계좌 정보 카드
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                HStack(spacing: 10) {
                                    // 신한 로고 (파란 원)
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text("S")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("입출금 [급여거래한도계...]")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text("신한 110-123-456789")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Button("설정") {
                                    // 하드코딩
                                }
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            }
                            
                            HStack(alignment: .bottom, spacing: 5) {
                                Text("5,250")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("원")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                            }
                            
                            HStack(spacing: 15) {
                                Button("돈보내기") {
                                    // 하드코딩
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.black)
                                
                                Button("금여클럽+") {
                                    // 하드코딩
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.black)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.1), radius: 5)
                        .padding(.horizontal, 20)
                        
                        // 지켜요 카드
                        HStack {
                            HStack(spacing: 15) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.white)
                                    )
                                
                                Text("지켜요(금융사기 예방)")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.1), radius: 5)
                        .padding(.horizontal, 20)
                        
                        // 서비스 그리드
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            ServiceCard(icon: "magnifyingglass", title: "전체계좌조회", color: .gray)
                            ServiceCard(icon: "paperplane.fill", title: "돈보내기", color: .orange)
                            
                            // 정산하기 버튼 (실제 동작)
                            NavigationLink(destination: ContactSelectionView()) {
                                VStack(spacing: 15) {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "person.2.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text("정산하기")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.1), radius: 5)
                            }
                            .onTapGesture {
                                print("🔥 정산하기 버튼 탭됨!")
                            }

                            
                            ServiceCard(icon: "building.2.fill", title: "ATM 찾기", color: .blue)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
                .background(Color.gray.opacity(0.05))
                
                // 하단 탭바
                HStack {
                    TabBarItem(icon: "house.fill", title: "홈", isSelected: true)
                    TabBarItem(icon: "clock", title: "자산관리", isSelected: false)
                    TabBarItem(icon: "cart", title: "상품", isSelected: false)
                    TabBarItem(icon: "calendar", title: "혜택", isSelected: false)
                    TabBarItem(icon: "grid.circle", title: "전체메뉴", isSelected: false)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5)
            }
            .background(Color.gray.opacity(0.05))
            .ignoresSafeArea(.all, edges: [.top, .bottom])
        }
        .navigationBarHidden(true)
    }
}

// 서비스 카드 컴포넌트
struct ServiceCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 15) {
            Circle()
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

// 탭바 아이템
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isSelected ? .blue : .gray)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
