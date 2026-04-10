// Toggle logic for forms
function switchForm(formType) {
    const loginBtn = document.getElementById('btn-login');
    const regBtn = document.getElementById('btn-register');
    const indicator = document.getElementById('toggle-indicator');
    
    const loginForm = document.getElementById('login-form');
    const regForm = document.getElementById('register-form');

    // Clear errors
    document.getElementById('login-error').innerText = '';
    document.getElementById('reg-error').innerText = '';

    if (formType === 'register') {
        loginBtn.classList.remove('active');
        regBtn.classList.add('active');
        indicator.style.transform = 'translateX(100%)';
        
        loginForm.classList.remove('active-form');
        loginForm.classList.add('hidden-form', 'shift-left');
        
        setTimeout(() => {
            regForm.classList.remove('hidden-form');
            regForm.classList.add('active-form');
        }, 100);

    } else {
        regBtn.classList.remove('active');
        loginBtn.classList.add('active');
        indicator.style.transform = 'translateX(0)';

        regForm.classList.remove('active-form');
        regForm.classList.add('hidden-form');
        
        setTimeout(() => {
            loginForm.classList.remove('hidden-form', 'shift-left');
            loginForm.classList.add('active-form');
        }, 100);
    }
}

// API Connection Logic
const API_BASE = 'http://localhost:8081/api/auth';

document.getElementById('login-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('login-submit');
    const errorDiv = document.getElementById('login-error');
    
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;

    btn.classList.add('loading');
    btn.disabled = true;
    errorDiv.innerText = '';

    try {
        const res = await fetch(`${API_BASE}/login`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ email, password })
        });
        
        const data = await res.json();
        
        if (!res.ok) {
            // Handle specific field errors or general error message
            throw new Error(data.error || extractValidationErrors(data));
        }

        showModal(`Welcome back, ${data.fullName}!`, 'You have successfully logged in as ' + data.role);
    } catch (err) {
        errorDiv.innerText = err.message || 'Unable to connect to server. Is it running?';
    } finally {
        btn.classList.remove('loading');
        btn.disabled = false;
    }
});

document.getElementById('register-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('reg-submit');
    const errorDiv = document.getElementById('reg-error');

    const fullName = document.getElementById('reg-name').value;
    const email = document.getElementById('reg-email').value;
    const password = document.getElementById('reg-password').value;
    const role = document.getElementById('reg-role').value;

    btn.classList.add('loading');
    btn.disabled = true;
    errorDiv.innerText = '';

    try {
        const res = await fetch(`${API_BASE}/register`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ fullName, email, password, role })
        });

        const data = await res.json();

        if (!res.ok) {
            throw new Error(data.error || extractValidationErrors(data));
        }

        showModal('Registration Successful!', `Account for ${data.email} has been created.`);
        // Optionally switch to login tab after success
        setTimeout(() => { switchForm('login'); }, 2000);
    } catch (err) {
        errorDiv.innerText = err.message || 'Unable to connect to server.';
    } finally {
        btn.classList.remove('loading');
        btn.disabled = false;
    }
});

// Helper to parse Validation Hashmap from Spring Boot
function extractValidationErrors(data) {
    if (typeof data === 'object') {
        const msgs = Object.values(data);
        if (msgs.length > 0) return msgs[0];
    }
    return 'Invalid data provided.';
}

// Modal Logic
function showModal(title, msg) {
    document.getElementById('modal-title').innerText = title;
    document.getElementById('modal-msg').innerText = msg;
    document.getElementById('success-modal').classList.add('show');
}

function closeModal() {
    document.getElementById('success-modal').classList.remove('show');
}

// Additional feature wiring for dashboard and token flows
async function getDashboardAnalytics() {
    try {
        const res = await fetch(`${API_BASE.replace('/api/auth', '')}/dashboard/analytics`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Unable to fetch dashboard analytics');

        alert(`Dashboard:\nTotal Revenue: $${data.totalRevenue}\nTotal Expenses: $${data.totalExpenses}\nProfit/Loss: $${data.profitLoss}\nPatient Count: ${data.patientCount}`);
    } catch (err) {
        alert('Dashboard load failed: ' + err.message);
    }
}

async function requestPatientToken(patientId, mdId, type = 'CHAT', notes = 'Patient request') {
    try {
        const res = await fetch(`${API_BASE.replace('/api/auth', '')}/patient/tokens`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ patientId, mdId, type })
        });
        const data = await res.text();
        if (!res.ok) throw new Error(data);
        alert('Token request sent successfully');
    } catch (err) {
        alert('Token request failed: ' + err.message);
    }
}
