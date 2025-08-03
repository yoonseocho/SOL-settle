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
    
    console.log('정산 요청 정보:', { 
        amount: params.amount, 
        sender: params.sender,
        formattedAmount: formattedAmount 
    });
}

// 신한SOL 클릭 처리
function handleShinhanClick() {
    const params = getURLParams();
    alert(`신한SOL 앱으로 이동합니다.\n송금 금액: ₩${formatAmount(params.amount)}\n요청자: ${params.sender}`);
    
    // 실제로는 신한SOL 앱의 딥링크나 웹뱅킹으로 이동
    // window.location.href = 'shinhan://transfer?amount=' + params.amount + '&from=' + params.sender;
    
    console.log('신한SOL 클릭됨:', params);
}

// 페이지 로드시 초기화
window.onload = initializePage;
