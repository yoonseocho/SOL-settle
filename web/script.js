// URL 파라미터에서 정보 추출
function getURLParams() {
    const urlParams = new URLSearchParams(window.location.search);
    return {
        amount: urlParams.get('amount') || '0',
        sender: urlParams.get('sender') || '정산대장'
    };
}

// 금액 포맷팅 (천단위 콤마)
function formatAmount(amount) {
    return new Intl.NumberFormat('ko-KR').format(amount);
}

// 페이지 초기화
function initializePage() {
    const params = getURLParams();
    
    // 발송자 이름 설정 (URL 파라미터에서 받은 실제 값)
    document.getElementById('sender-name').textContent = params.sender;
    
    // 금액 설정 (포맷팅)
    const formattedAmount = formatAmount(params.amount);
    document.getElementById('amount').textContent = `₩${formattedAmount}`;

    // 모든 은행 화면에 정보 설정
    const banks = ['toss', 'kakao', 'kb', 'hana', 'woori', 'nh'];
    banks.forEach(bank => {
        const amountElement = document.getElementById(`${bank}-amount`);
        const senderElement = document.getElementById(`${bank}-sender`);
        if (amountElement) amountElement.textContent = `₩${formattedAmount}`;
        if (senderElement) senderElement.textContent = params.sender;
    });
    
    console.log('정산 요청 정보:', { 
        amount: params.amount, 
        sender: params.sender,
        formattedAmount: formattedAmount 
    });
}

// 신한SOL 클릭 처리
function handleShinhanClick() {
    const params = getURLParams();
    
    // iOS 앱으로 딥링크 호출
    const deepLink = `solsettle://transfer?amount=${params.amount}&sender=${encodeURIComponent(params.sender)}`;
    
    console.log('딥링크 호출:', deepLink);
    
    // iOS 앱이 설치되어 있으면 딥링크로, 없으면 앱스토어로
    window.location.href = deepLink;
    
    // 앱이 없을 경우를 대비한 폴백 (3초 후)
    setTimeout(() => {
        // 여기에 앱스토어 링크를 넣을 수 있음
        console.log('앱이 설치되지 않은 것 같습니다.');
    }, 3000);
}

// 은행 화면 표시
function showBankScreen(bankName) {
    const screen = document.getElementById(`${bankName}-screen`);
    if (screen) {
        screen.style.display = 'flex';
    }
}

// 은행 화면 닫기
function closeBankScreen(screenId) {
    const screen = document.getElementById(screenId);
    if (screen) {
        screen.style.display = 'none';
    }
}

// 송금 완료 처리
function completeBankTransfer(bankName) {
    const params = getURLParams();
    alert(`${bankName}에서 송금이 완료되었습니다!\n\n금액: ${formatAmount(params.amount)}원\n받는 사람: ${params.sender}님`);
    
    // 화면 닫기
    const overlays = document.querySelectorAll('.bank-overlay');
    overlays.forEach(overlay => overlay.style.display = 'none');
}

// 페이지 로드시 초기화
window.onload = initializePage;
