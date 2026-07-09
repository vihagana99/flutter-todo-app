
if (Api.getToken()) {
  window.location.href = 'index.html';
}

const loginBtn = document.getElementById('loginBtn');
const errorBox = document.getElementById('errorBox');

function showError(message) {
  errorBox.textContent = message;
  errorBox.style.display = 'block';
}

loginBtn.addEventListener('click', async () => {
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value.trim();

  if (!email || !password) {
    showError('Please fill in both fields');
    return;
  }

  loginBtn.disabled = true;
  loginBtn.textContent = 'Signing in...';

  const result = await Api.login(email, password);

  loginBtn.disabled = false;
  loginBtn.textContent = 'Sign In';

  if (result.success) {
    window.location.href = 'index.html';
  } else {
    showError(result.message);
  }
});

// Allow submitting with Enter key
document.getElementById('password').addEventListener('keydown', (e) => {
  if (e.key === 'Enter') loginBtn.click();
});
