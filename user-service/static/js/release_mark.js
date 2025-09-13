async function sendReleaseMark() {
  const btn = document.getElementById('release-btn');
  const appInput = document.getElementById('app-name-input');
  const msgInput = document.getElementById('release-message-input');

  const appName = appInput.value.trim();
  const message = msgInput.value.trim();

  if (!appName) {
    alert("애플리케이션 이름을 입력해 주세요.");
    return;
  }
  if (!message) {
    alert("보낼 메시지를 입력해 주세요.");
    return;
  }

  btn.disabled = true;
  btn.innerText = 'Sending...';

  try {
    const resp = await fetch('/release_mark', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({application_name: appName, message: message})
    });

    if (!resp.ok) {
      const errorData = await resp.json();
      alert(`에러 발생: ${errorData.message || resp.statusText}`);
      return;
    }
    const result = await resp.json();
    alert(result.message);

  } catch (e) {
    alert('Release mark 전송 중 네트워크 오류 또는 예외 발생');
    console.error(e);
  }

  btn.disabled = false;
  btn.innerText = 'Release Mark 보내기';
}

