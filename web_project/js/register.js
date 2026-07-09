if (Api.getToken()) {
  window.location.href = 'index.html';
}

const registerBtn = document.getElementById('registerBtn');
const errorBox = document.getElementById('errorBox');

function showError(message) {
  errorBox.textContent = message;
  errorBox.style.display = 'block';
}

registerBtn.addEventListener('click', async () => {
  const name = document.getElementById('name').value.trim();
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value.trim();

  if (!name || !email || !password) {
    showError('Please fill in all fields');
    return;
  }

  registerBtn.disabled = true;
  registerBtn.textContent = 'Creating account...';

  const result = await Api.register(name, email, password);

  registerBtn.disabled = false;
  registerBtn.textContent = 'Create Account';

  if (result.success) {
    window.location.href = 'index.html';
  } else {
    showError(result.message);
  }
});
