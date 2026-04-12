const API_BASE = '/api';
let currentUser = null;
let activeChatTokenId = null;
let chatPollInterval = null;

// ── HAMBURGER MENU ──
function toggleNavMenu() {
    const links = document.getElementById('nav-links');
    const btn   = document.getElementById('nav-hamburger');
    if (!links || !btn) return;
    const isOpen = links.classList.toggle('nav-open');
    btn.classList.toggle('open', isOpen);
}
document.addEventListener('click', (e) => {
    const links = document.getElementById('nav-links');
    const btn   = document.getElementById('nav-hamburger');
    if (links && btn && !btn.contains(e.target) && !links.contains(e.target)) {
        links.classList.remove('nav-open');
        btn.classList.remove('open');
    }
});

// ========================
// AUTH TOGGLE
// ========================
function showAuthForm(id) {
    ['login-form','register-form','forgot-form','force-reset-form'].forEach(f => {
        const el = document.getElementById(f);
        if (el) el.className = 'auth-form hidden-form';
    });
    const target = document.getElementById(id);
    if (target) target.className = 'auth-form active-form';
}

function switchForm(formType) {
    const loginBtn = document.getElementById('btn-login');
    const regBtn   = document.getElementById('btn-register');
    const indicator = document.getElementById('toggle-indicator');
    document.getElementById('login-error').innerText = '';
    document.getElementById('reg-error').innerText = '';
    if (formType === 'register') {
        loginBtn.classList.remove('active'); regBtn.classList.add('active');
        indicator.style.transform = 'translateX(100%)';
        showAuthForm('register-form');
    } else {
        regBtn.classList.remove('active'); loginBtn.classList.add('active');
        indicator.style.transform = 'translateX(0)';
        showAuthForm('login-form');
    }
}

// ========================
// FORGOT / TEMP PASSWORD
// ========================
function showForgotForm() {
    showAuthForm('forgot-form');
}

function cancelForgot() {
    showAuthForm('login-form');
    document.getElementById('otp-group').classList.add('hidden');
    document.getElementById('forgot-submit').innerText = 'Send OTP via Email';
    document.getElementById('forgot-email').readOnly = false;
}

document.getElementById('forgot-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('forgot-submit');
    const email = document.getElementById('forgot-email').value;
    const otpGroup = document.getElementById('otp-group');
    if (otpGroup.classList.contains('hidden')) {
        try {
            await fetch(`${API_BASE}/auth/forgot-password?email=${encodeURIComponent(email)}`, { method: 'POST' });
            alert("OTP generated. Check the Spring Boot Console for the Mock OTP.");
            otpGroup.classList.remove('hidden');
            document.getElementById('forgot-email').readOnly = true;
            btn.innerText = 'Confirm New Password';
        } catch(err) { alert('Failed to trigger process'); }
    } else {
        const otp = document.getElementById('forgot-otp').value;
        const newPwd = document.getElementById('forgot-new-pwd').value;
        try {
            const res = await fetch(`${API_BASE}/auth/reset-password-otp?email=${encodeURIComponent(email)}&otp=${otp}&newPassword=${newPwd}`, { method: 'POST' });
            if (!res.ok) throw new Error('Invalid/Expired OTP');
            alert('Password updated! Please login.');
            cancelForgot();
        } catch(err) { alert(err.message); }
    }
});

let forceResetUserData = null;
document.getElementById('force-reset-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const newPwd = document.getElementById('force-new-pwd').value;
    const email = document.getElementById('force-email').value;
    try {
        const res = await fetch(`${API_BASE}/auth/reset-password-temp?email=${encodeURIComponent(email)}&currentPassword=temp@123&newPassword=${newPwd}`, { method: 'POST' });
        if (!res.ok) throw new Error('Reset rejected.');
        alert('Account Secured! Transitioning...');
        showAuthForm('login-form');
        initApp(forceResetUserData);
    } catch(err) { alert('Failed: ' + err.message); }
});

// ========================
// LOGIN & REGISTER
// ========================
document.getElementById('login-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('login-submit');
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    btn.classList.add('loading'); btn.disabled = true;
    try {
        const res = await fetch(`${API_BASE}/auth/login`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ email, password })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || data.email || data.password || 'Login failed');
        if (data.requirePasswordReset) {
            forceResetUserData = data;
            document.getElementById('force-email').value = email;
            showAuthForm('force-reset-form');
        } else {
            initApp(data);
        }
    } catch (err) {
        document.getElementById('login-error').innerText = err.message;
    } finally {
        btn.classList.remove('loading'); btn.disabled = false;
    }
});

document.getElementById('register-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('reg-submit');
    const fullName = document.getElementById('reg-name').value;
    const email = document.getElementById('reg-email').value;
    const password = document.getElementById('reg-password').value;
    btn.classList.add('loading'); btn.disabled = true;
    try {
        const res = await fetch(`${API_BASE}/auth/register`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ fullName, email, password })
        });
        if (!res.ok) throw new Error('Registration failed');
        alert('Registered! Role defaults to PATIENT. Please login.');
        switchForm('login');
    } catch (err) {
        document.getElementById('reg-error').innerText = err.message;
    } finally {
        btn.classList.remove('loading'); btn.disabled = false;
    }
});

// ========================
// INIT APP
// ========================
function initApp(userData) {
    currentUser = userData;
    document.getElementById('auth-container').classList.add('hidden');
    document.getElementById('app-container').classList.remove('hidden');
    document.getElementById('user-badge').innerText = `${userData.fullName} (${userData.role})`;
    document.getElementById('md-dashboard').classList.add('hidden');
    document.getElementById('doctor-dashboard').classList.add('hidden');
    document.getElementById('patient-dashboard').classList.add('hidden');
    if (userData.role === 'MAIN_DOCTOR') {
        document.getElementById('md-dashboard').classList.remove('hidden');
        const fab = document.getElementById('emergency-fab');
        if (fab) fab.style.display = 'none';
        loadMDDashboard();
        loadMDQueues();
        loadMDEmergencyQueue();
        setInterval(loadMDEmergencyQueue, 8000);
    } else if (userData.role === 'DOCTOR') {
        document.getElementById('doctor-dashboard').classList.remove('hidden');
        const fab = document.getElementById('emergency-fab');
        if (fab) fab.style.display = 'none';
        loadDoctorDashboard();
    } else {
        document.getElementById('patient-dashboard').classList.remove('hidden');
        const fab = document.getElementById('emergency-fab');
        if (fab) fab.style.display = 'block';
        loadPatientDashboard();
        // Show notification bell for patients
        const notifWrap = document.getElementById('notif-wrap');
        if (notifWrap) notifWrap.style.display = 'block';
        loadNotifications();
        setInterval(loadNotifications, 15000);
    }
    loadSocialFeed();
}

function logout() {
    currentUser = null;
    clearInterval(window._notifInterval);
    const notifWrap = document.getElementById('notif-wrap');
    if (notifWrap) notifWrap.style.display = 'none';
    document.getElementById('auth-container').classList.remove('hidden');
    document.getElementById('app-container').classList.add('hidden');
    showAuthForm('login-form');
}

// ========================
// CHAT
// ========================
function renderTimeStatusButton(tk) {
    const isVideo = tk.type === 'VIDEO';
    const displayStr = tk.scheduledTime
        ? new Date(tk.scheduledTime).toLocaleString([], {dateStyle:'short', timeStyle:'short'})
        : '';
    const joinFn = isVideo ? `openVideoCall(${tk.id}, '${displayStr}')` : `openChat(${tk.id}, '${displayStr}')`;
    const joinLabel = isVideo ? '📹 Join Video Call' : '💬 Join Chat';
    return `<button class="submit-btn" style="width:160px;padding:10px;" onclick="${joinFn}">${joinLabel}</button>`;
}

function openChat(tokenId, scheduleTime) {
    activeChatTokenId = tokenId;
    openModal('chat-modal');
    document.getElementById('chat-schedule').innerText = scheduleTime ? `Session Authorized (${scheduleTime})` : 'Active Session';
    document.getElementById('chat-schedule').style.color = 'var(--accent-1)';
    document.getElementById('chat-messages').innerHTML = '<p class="text-muted" style="text-align:center;">Connecting...</p>';
    document.getElementById('chat-input').disabled = false;
    document.getElementById('chat-input').placeholder = 'Type secure message...';
    document.querySelector("button[onclick='sendChatMessage()']").classList.remove('hidden');
    const termBtn = document.getElementById('chat-terminate-btn');
    if (currentUser.role === 'MAIN_DOCTOR') termBtn.classList.remove('hidden');
    else termBtn.classList.add('hidden');
    pollChatMessages();
    chatPollInterval = setInterval(pollChatMessages, 3000);
}

function closeChat() {
    clearInterval(chatPollInterval);
    activeChatTokenId = null;
    closeModal('chat-modal');
    if (currentUser) {
        if (currentUser.role === 'MAIN_DOCTOR') loadMDQueues();
        else if (currentUser.role === 'PATIENT') loadPatientDashboard();
    }
}

// ========================
// VIDEO CALL
// ========================
let localStream = null;
let peerConnection = null;
let activeVideoTokenId = null;

function openVideoCall(tokenId, scheduleTime) {
    activeVideoTokenId = tokenId;
    document.getElementById('video-schedule').innerText = scheduleTime ? `Session: ${scheduleTime}` : 'Active Session';
    document.getElementById('video-terminate-btn').classList.toggle('hidden', currentUser.role !== 'MAIN_DOCTOR');
    openModal('video-modal');
    startLocalCamera();
}

async function startLocalCamera() {
    try {
        localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
        document.getElementById('local-video').srcObject = localStream;
    } catch(e) {
        alert('Camera/Microphone access denied or unavailable: ' + e.message);
    }
    const remoteVideo = document.getElementById('remote-video');
    remoteVideo.addEventListener('play', () => {
        const ph = document.getElementById('remote-placeholder');
        if (ph) ph.style.display = 'none';
    });
}

function closeVideoCall() {
    if (localStream) { localStream.getTracks().forEach(t => t.stop()); localStream = null; }
    if (peerConnection) { peerConnection.close(); peerConnection = null; }
    document.getElementById('local-video').srcObject = null;
    document.getElementById('remote-video').srcObject = null;
    const ph = document.getElementById('remote-placeholder');
    if (ph) ph.style.display = 'flex';
    activeVideoTokenId = null;
    closeModal('video-modal');
    if (currentUser) {
        if (currentUser.role === 'MAIN_DOCTOR') loadMDQueues();
        else loadPatientDashboard();
    }
}

async function terminateVideoSession() {
    if (!confirm('End this video session?')) return;
    try {
        const res = await fetch(`${API_BASE}/md/tokens/${activeVideoTokenId}/terminate`, { method: 'PUT' });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        closeVideoCall();
    } catch(e) { alert('Failed: ' + e.message); }
}

async function terminateSession() {
    if (!confirm('End this session? This permanently locks the chat.')) return;
    try {
        const res = await fetch(`${API_BASE}/md/tokens/${activeChatTokenId}/terminate`, { method: 'PUT' });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        document.getElementById('chat-schedule').innerText = 'Session Permanently Archived';
        document.getElementById('chat-schedule').style.color = 'red';
        closeChat();
    } catch(e) { alert('Failed: ' + e.message); }
}

async function pollChatMessages() {
    if (!activeChatTokenId) return;
    try {
        const res = await fetch(`${API_BASE}/chat/${activeChatTokenId}`);
        const data = await res.json();
        if (data.isTerminated && !document.getElementById('chat-input').disabled) {
            document.getElementById('chat-schedule').innerText = 'Session Permanently Archived';
            document.getElementById('chat-schedule').style.color = 'red';
            document.getElementById('chat-input').disabled = true;
            document.getElementById('chat-input').placeholder = 'Session Terminated.';
            document.getElementById('chat-input').value = '';
            document.querySelector("button[onclick='sendChatMessage()']").classList.add('hidden');
            if (currentUser.role === 'MAIN_DOCTOR') document.getElementById('chat-terminate-btn').classList.add('hidden');
            if (currentUser.role === 'PATIENT') loadPatientDashboard();
        }
        const box = document.getElementById('chat-messages');
        let html = '';
        data.messages.forEach(msg => {
            const isMe = msg.senderId === currentUser.userId;
            const al = isMe ? 'right' : 'left';
            const bg = isMe ? 'var(--primary)' : 'rgba(255,255,255,0.1)';
            html += `<div style="text-align:${al};margin-bottom:5px;">
                <div style="display:inline-block;max-width:70%;background:${bg};padding:10px 15px;border-radius:15px;text-align:left;">
                    <div style="font-size:0.75rem;opacity:0.7;margin-bottom:3px;">${msg.senderName}</div>
                    <div>${msg.message}</div>
                </div></div>`;
        });
        box.innerHTML = html;
        box.scrollTop = box.scrollHeight;
    } catch(e) {}
}

async function sendChatMessage() {
    const ipt = document.getElementById('chat-input');
    const msg = ipt.value;
    if (!msg.trim() || !activeChatTokenId) return;
    ipt.value = '';
    try {
        await fetch(`${API_BASE}/chat/${activeChatTokenId}?senderId=${currentUser.userId}`, {
            method: 'POST', headers: {'Content-Type': 'text/plain'}, body: msg
        });
        pollChatMessages();
    } catch(e) { alert('Session frozen by MD.'); }
}

// ========================
// MAIN DOCTOR DASHBOARD
// ========================
async function loadMDDashboard() {
    try {
        const res = await fetch(`${API_BASE}/md/dashboard`);
        const data = await res.json();
        document.getElementById('md-rev').innerText = data.totalRevenue || '0.0';
        document.getElementById('md-exp').innerText = data.totalExpenses || '0.0';
        document.getElementById('md-profit').innerText = data.profitLoss || '0.0';
        document.getElementById('md-patients').innerText = data.patientCount || '0';
        if (document.getElementById('md-appointments-count')) document.getElementById('md-appointments-count').innerText = data.totalAppointments || '0';
        if (document.getElementById('md-pending-refs')) document.getElementById('md-pending-refs').innerText = data.pendingReferrals || '0';
        if (document.getElementById('md-pending-tokens')) document.getElementById('md-pending-tokens').innerText = data.pendingTokenRequests || '0';
        if (document.getElementById('md-activity') && data.doctorActivity) {
            const actHtml = Object.entries(data.doctorActivity).map(([name, count]) =>
                `<div class="activity-row"><span>Dr. ${name}</span><span class="activity-badge">${count} consultations</span></div>`
            ).join('');
            document.getElementById('md-activity').innerHTML = actHtml || '<p class="text-muted">No activity yet.</p>';
        }
    } catch(e) { console.warn('Analytics fetch failed'); }

    try {
        const pRes = await fetch(`${API_BASE}/md/patients`);
        const dRes = await fetch(`${API_BASE}/md/doctors`);
        const patData = await pRes.json();
        const docData = await dRes.json();
        const pSelect = document.getElementById('md-assign-patient');
        const dSelect = document.getElementById('md-assign-doctor');
        if (pSelect && dSelect) {
            pSelect.innerHTML = '<option value="">-- Select Patient --</option>' +
                patData.map(p => `<option value="${p.id}">${p.fullName} [${p.historySummary}]</option>`).join('');
            dSelect.innerHTML = '<option value="">-- Select Doctor --</option>' +
                docData.map(d => `<option value="${d.id}">Dr. ${d.fullName} (${d.specialty || d.historySummary})</option>`).join('');
        }
    } catch(e) { console.error('Assignment fetch error'); }

    await loadMDDirectory();
}

async function loadMDDirectory() {
    try {
        const res = await fetch(`${API_BASE}/md/doctors`);
        const docs = await res.json();
        const container = document.getElementById('md-directory-list');
        if (!docs.length) { container.innerHTML = '<p class="text-muted">No Active Doctors.</p>'; return; }
        let html = '';
        docs.forEach(d => {
            html += `<div class="queue-card" onclick="openMDDoctorView(${d.id}, '${d.fullName}')" style="cursor:pointer;border-left:4px solid var(--accent-1);margin-bottom:10px;">
                <div style="flex:1;">
                    <h4 style="margin:0;color:var(--primary);">Dr. ${d.fullName}</h4>
                    <p class="text-muted" style="margin:5px 0 0 0;font-size:0.85rem;">Specialty: ${d.specialty || d.historySummary}</p>
                </div>
                <button class="submit-btn outline" style="width:auto;padding:5px 15px;">Inspect</button>
            </div>`;
        });
        container.innerHTML = html;
    } catch(e) { console.error('Directory Error', e); }
}

async function openMDDoctorView(docId, docName) {
    document.getElementById('inspect-doc-name').innerText = 'Dr. ' + docName;
    document.getElementById('inspect-doc-patients').innerHTML = '<p class="text-muted">Loading...</p>';
    openModal('md-doctor-inspect-modal');
    try {
        const res = await fetch(`${API_BASE}/md/doctors/${docId}/patients`);
        const pats = await res.json();
        const container = document.getElementById('inspect-doc-patients');
        if (!pats.length) { container.innerHTML = '<p class="text-muted">No patients assigned.</p>'; return; }
        let html = '';
        pats.forEach(p => {
            const ageBadge = p.age ? `<span class="age-badge">Age: ${p.age}</span>` : '';
            html += `<div class="queue-card" onclick="openMDPatientInspector(${p.id}, '${p.fullName}')" style="cursor:pointer;background:rgba(255,255,255,0.05);margin-bottom:10px;border-left:3px solid var(--accent-2);">
                <div style="flex:1;"><h4 style="margin:0;">${p.fullName} ${ageBadge}</h4></div>
                <button class="submit-btn outline" style="width:auto;padding:5px 15px;border-color:var(--accent-2);color:var(--accent-2);">View History</button>
            </div>`;
        });
        container.innerHTML = html;
    } catch(e) { document.getElementById('inspect-doc-patients').innerHTML = '<p class="error-msg">Failed.</p>'; }
}

async function openMDPatientInspector(patId, patName) {
    closeModal('md-doctor-inspect-modal');
    document.getElementById('inspect-pat-name').innerText = patName + ' — Clinical Timeline';
    const container = document.getElementById('inspect-pat-timeline');
    container.innerHTML = '<p class="text-muted" style="padding:10px;">Loading...</p>';
    openModal('md-patient-inspect-modal');
    try {
        const res = await fetch(`${API_BASE}/md/patients/${patId}/history`);
        const hist = await res.json();
        if (!hist.length) {
            container.innerHTML = '<p class="text-muted" style="padding:16px;text-align:center;">No medical history available.</p>';
            return;
        }
        container.innerHTML = hist.map((h, i) => {
            const date = new Date(h.date).toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'numeric' });
            const rxHtml = h.prescription
                ? `<div style="margin-top:8px;padding:8px 12px;background:#f0fdf4;border-radius:8px;border-left:3px solid var(--green);">
                    <span style="font-size:0.75rem;font-weight:700;color:var(--green);text-transform:uppercase;letter-spacing:0.5px;">💊 Prescription</span>
                    <p style="margin:4px 0 0;font-size:0.88rem;color:var(--text-main);">${h.prescription}</p>
                   </div>` : '';
            const refHtml = h.referralInfo
                ? `<p style="margin-top:6px;font-size:0.8rem;color:var(--text-muted);">🔁 ${h.referralInfo}</p>` : '';
            const reportBtn = h.reportsUrl
                ? `<button onclick="viewHistoryReport(${JSON.stringify(h).replace(/"/g,'&quot;')})"
                    style="margin-top:10px;background:var(--primary-light);border:1.5px solid var(--primary);color:var(--primary);padding:6px 14px;border-radius:8px;font-size:0.82rem;font-weight:600;cursor:pointer;display:inline-flex;align-items:center;gap:6px;">
                    📎 View Report
                   </button>` : '';
            return `<div style="background:var(--card-bg);border:1px solid var(--border);border-radius:12px;padding:16px 18px;margin-bottom:12px;box-shadow:var(--shadow-sm);">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
                    <span style="font-size:0.78rem;font-weight:700;color:var(--primary);background:var(--primary-light);padding:3px 10px;border-radius:20px;">📅 ${date}</span>
                    <span style="font-size:0.8rem;font-weight:600;color:var(--text-muted);">Dr. ${h.doctorName}</span>
                </div>
                <div style="margin-bottom:4px;">
                    <span style="font-size:0.75rem;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.5px;">📋 Diagnosis</span>
                    <p style="margin:4px 0 0;font-size:0.9rem;color:var(--text-main);line-height:1.5;">${h.notes || '—'}</p>
                </div>
                ${rxHtml}${refHtml}${reportBtn}
            </div>`;
        }).join('');
    } catch(e) {
        container.innerHTML = '<p style="color:var(--danger);padding:16px;">Failed to load history.</p>';
    }
}

async function executeDirectAssignment() {
    const pId = document.getElementById('md-assign-patient').value;
    const dId = document.getElementById('md-assign-doctor').value;
    const pName = document.getElementById('md-assign-patient').options[document.getElementById('md-assign-patient').selectedIndex]?.text || '';
    const dName = document.getElementById('md-assign-doctor').options[document.getElementById('md-assign-doctor').selectedIndex]?.text || '';
    if (!pId || !dId) return alert('Please select both a Patient and a Doctor.');
    if (!confirm(`Assign ${pName} to ${dName}?`)) return;
    try {
        const res = await fetch(`${API_BASE}/md/patients/${pId}/assign?doctorId=${dId}`, { method: 'PUT' });
        if (!res.ok) throw new Error('Server rejected.');
        alert(`✅ Patient assigned to ${dName} successfully!`);
        loadMDDashboard();
    } catch(e) { alert('Failed: ' + e.message); }
}

async function loadMDQueues() {
    try {
        const res = await fetch(`${API_BASE}/md/queues`);
        const data = await res.json();
        const container = document.getElementById('md-queues');
        container.innerHTML = '';
        let hasItems = false;

        if (data.referrals && data.referrals.length > 0) {
            hasItems = true;
            const docRes = await fetch(`${API_BASE}/md/doctors`);
            const activeDocs = await docRes.json();
            const docOptionsHtml = activeDocs.map(d => `<option value="${d.id}">Dr. ${d.fullName} (${d.specialty || d.historySummary})</option>`).join('');
            data.referrals.forEach(r => {
                container.innerHTML += `<div class="card" style="border-left:4px solid var(--primary);">
                    <h4>Referral Request (ID: ${r.id})</h4>
                    <p><strong>From:</strong> Dr. ${r.fromDoctor}</p>
                    <p><strong>Patient:</strong> ${r.patientName}</p>
                    <p><strong>Dept:</strong> ${r.requestedSpecialty} — Urgency: <span style="color:var(--accent-1);font-weight:bold;">${r.urgency}</span></p>
                    <p><strong>Reason:</strong> "${r.reason}"</p>
                    <div class="card-actions mt-2" style="align-items:center;">
                        <select id="assign-doc-${r.id}" class="modal-input" style="max-width:280px;margin:0;">
                            <option value="">-- Assign Doctor --</option>${docOptionsHtml}
                        </select>
                        <button class="submit-btn" style="padding:10px;width:auto;margin:0;" onclick="processReferral(${r.id}, true)">Approve</button>
                        <button class="submit-btn danger" style="padding:10px;width:auto;margin:0;" onclick="processReferral(${r.id}, false)">Reject</button>
                    </div>
                </div>`;
            });
        }

        if (data.tokens && data.tokens.length > 0) {
            hasItems = true;
            data.tokens.forEach(t => {
                container.innerHTML += `<div class="card" style="border-left:4px solid var(--accent-1);">
                    <h4>${t.type} Request (ID: ${t.id})</h4>
                    <p><strong>Patient:</strong> ${t.patientName}</p>
                    <div class="card-actions mt-2">
                        <button class="submit-btn" style="padding:8px;" onclick="processToken(${t.id}, true)">Approve & Schedule</button>
                        <button class="submit-btn danger" style="padding:8px;" onclick="processToken(${t.id}, false)">Reject</button>
                    </div>
                </div>`;
            });
        }

        if (!hasItems) container.innerHTML = '<p class="text-muted" style="padding:20px;">No pending actions.</p>';

        const aptRes = await fetch(`${API_BASE}/md/appointments`);
        const aptData = await aptRes.json();
        const aptContainer = document.getElementById('md-appointments');
        aptContainer.innerHTML = '';
        if (aptData.length === 0) {
            aptContainer.innerHTML = '<p class="text-muted" style="padding:20px;">No active sessions.</p>';
        } else {
            aptData.forEach(a => {
                const btnHtml = renderTimeStatusButton(a);
                const schedInfo = a.scheduledTime
                    ? `<small style="color:var(--accent-1);">📅 ${new Date(a.scheduledTime).toLocaleString([], {dateStyle:'short', timeStyle:'short'})}</small>`
                    : '';
                const icon = a.type === 'VIDEO' ? '📹' : '💬';
                aptContainer.innerHTML += `<div class="card" style="display:flex;justify-content:space-between;align-items:center;border-left:4px solid var(--success);">
                    <div>
                        <h4 style="margin:0;">${icon} Patient: ${a.patientName} (${a.type})</h4>
                        ${schedInfo}
                    </div>
                    <div>${btnHtml}</div>
                </div>`;
            });
        }
    } catch(e) { console.error('Queue fetch error', e); }
}

async function processReferral(id, approve) {
    let url = `${API_BASE}/md/referrals/${id}/assign?approve=${approve}`;
    if (approve) {
        const selectBox = document.getElementById(`assign-doc-${id}`);
        if (!selectBox.value) return alert('Select a Doctor to assign!');
        url += `&assignedDoctorId=${selectBox.value}`;
    }
    try {
        await fetch(url, { method: 'PUT' });
        alert(approve ? 'Referral approved & patient transferred.' : 'Referral rejected.');
        loadMDQueues();
    } catch(e) { alert('Failed.'); }
}

function processToken(id, approve) {
    if (approve) {
        document.getElementById('assign-token-id').value = id;
        document.getElementById('assign-time').value = '';
        openModal('md-assign-modal');
    } else {
        fetch(`${API_BASE}/md/tokens/${id}?approve=false`, { method: 'PUT' }).then(() => loadMDQueues());
    }
}

async function submitTokenApproval() {
    const id = document.getElementById('assign-token-id').value;
    const sched = document.getElementById('assign-time').value;
    if (!sched) return alert('Select a scheduled time!');
    await fetch(`${API_BASE}/md/tokens/${id}?approve=true&scheduledTime=${encodeURIComponent(sched)}`, { method: 'PUT' });
    closeModal('md-assign-modal');
    loadMDQueues();
}

async function submitPromote() {
    const email = document.getElementById('prom-email').value;
    const name = document.getElementById('prom-name').value;
    const role = document.getElementById('prom-role').value;
    try {
        const res = await fetch(`${API_BASE}/md/promote?email=${encodeURIComponent(email)}&name=${encodeURIComponent(name)}&role=${role}`, { method: 'POST' });
        if (!res.ok) throw new Error('Failed');
        alert('User role updated. New users get password: temp@123');
        closeModal('promote-modal');
        loadMDDashboard();
    } catch(e) { alert('Failed.'); }
}

function downloadReport(type, format) {
    const map = {
        revenue:  { pdf: `${API_BASE}/md/reports/revenue/pdf`,  excel: `${API_BASE}/md/reports/revenue/excel` },
        expenses: { pdf: `${API_BASE}/md/reports/expenses/pdf`, excel: `${API_BASE}/md/reports/expenses/excel` },
        doctors:  { pdf: `${API_BASE}/md/reports/doctors/pdf`,  excel: `${API_BASE}/md/reports/doctors/excel` }
    };
    const url = map[type][format];
    const ext = format === 'pdf' ? 'pdf' : 'xlsx';
    const a = document.createElement('a');
    a.href = url;
    a.download = `${type}_report.${ext}`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}

function downloadMedicalReport(report) {
    if (!report || !report.fileUrl) return alert('File not available.');
    const url  = report.fileUrl;
    const name = report.reportName || 'report';
    if (url.startsWith('data:')) {
        const [meta, base64] = url.split(',');
        const mime   = meta.match(/:(.*?);/)[1];
        const binary = atob(base64);
        const arr    = new Uint8Array(binary.length);
        for (let i = 0; i < binary.length; i++) arr[i] = binary.charCodeAt(i);
        const blob = new Blob([arr], { type: mime });
        const ext  = mime.includes('pdf') ? '.pdf' : mime.includes('png') ? '.png' : '.jpg';
        const a    = document.createElement('a');
        a.href     = URL.createObjectURL(blob);
        a.download = name + ext;
        document.body.appendChild(a); a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(a.href);
    } else {
        const a    = document.createElement('a');
        a.href     = url;
        a.download = name;
        a.target   = '_blank';
        document.body.appendChild(a); a.click();
        document.body.removeChild(a);
    }
}

async function postSocial() {
    const title = document.getElementById('ps-title').value;
    const content = document.getElementById('ps-content').value;
    const mediaUrl = document.getElementById('ps-media') ? document.getElementById('ps-media').value : '';
    if (!title || !content) return alert('Title and Content are required!');
    try {
        const res = await fetch(`${API_BASE}/md/social?mdId=${currentUser.userId}&title=${encodeURIComponent(title)}&content=${encodeURIComponent(content)}&mediaUrl=${encodeURIComponent(mediaUrl)}`, { method: 'POST' });
        if (res.ok) {
            alert('✅ Broadcast published!');
            document.getElementById('post-social-modal').classList.remove('show');
            document.getElementById('ps-title').value = '';
            document.getElementById('ps-content').value = '';
            if (document.getElementById('ps-media')) document.getElementById('ps-media').value = '';
            loadSocialFeed();
        }
    } catch(e) { alert('Failed to post'); }
}

// ========================
// DOCTOR DASHBOARD
// ========================
let allDoctorPatients = [];

async function loadDoctorDashboard() {
    const list = document.getElementById('doctor-patients-list');
    // Show skeleton
    list.innerHTML = `<div class="doc-skeleton">
        <div class="skeleton-card"></div>
        <div class="skeleton-card"></div>
        <div class="skeleton-card"></div>
    </div>`;

    try {
        const res = await fetch(`${API_BASE}/doctor/${currentUser.userId}/patients`);
        allDoctorPatients = await res.json();
        updateDoctorStats(allDoctorPatients);
        applyDoctorFilters();
    } catch(e) {
        list.innerHTML = `<div class="doc-empty"><div class="doc-empty-icon">⚠️</div><div class="doc-empty-text">Failed to load patients</div><div class="doc-empty-sub">Check your connection and try again.</div></div>`;
    }
}

function updateDoctorStats(data) {
    const total     = data.length;
    const active    = data.filter(p => p.lastConsultation).length;
    const referred  = data.filter(p => p.historySummary && p.historySummary.toLowerCase().includes('refer')).length;
    const noHistory = data.filter(p => !p.lastConsultation).length;
    document.getElementById('doc-stat-total').innerText     = total;
    document.getElementById('doc-stat-active').innerText    = active;
    document.getElementById('doc-stat-referred').innerText  = referred;
    document.getElementById('doc-stat-nohistory').innerText = noHistory;
}

function applyDoctorFilters() {
    const search = (document.getElementById('doc-search')?.value || '').toLowerCase();
    const status = document.getElementById('doc-filter-status')?.value || 'all';
    const sort   = document.getElementById('doc-sort')?.value || 'latest';

    let filtered = allDoctorPatients.filter(p => {
        const matchName = !search || p.fullName.toLowerCase().includes(search);
        const isActive    = !!p.lastConsultation;
        const isReferred  = p.historySummary?.toLowerCase().includes('refer');
        const isNoHistory = !p.lastConsultation;
        const matchStatus = status === 'all'
            || (status === 'active'    && isActive)
            || (status === 'referred'  && isReferred)
            || (status === 'nohistory' && isNoHistory);
        return matchName && matchStatus;
    });

    if (sort === 'latest') filtered.sort((a, b) => new Date(b.lastConsultation || 0) - new Date(a.lastConsultation || 0));
    else if (sort === 'oldest') filtered.sort((a, b) => new Date(a.lastConsultation || 0) - new Date(b.lastConsultation || 0));
    else if (sort === 'name') filtered.sort((a, b) => a.fullName.localeCompare(b.fullName));

    renderDoctorPatients(filtered);
}

function renderDoctorPatients(data) {
    const list = document.getElementById('doctor-patients-list');
    if (!data.length) {
        list.innerHTML = `<div class="doc-empty">
            <div class="doc-empty-icon">🏥</div>
            <div class="doc-empty-text">No patients found</div>
            <div class="doc-empty-sub">Try adjusting your search or filter.</div>
        </div>`;
        return;
    }

    list.innerHTML = data.map(p => {
        const name = p.fullName.replace(/'/g, "\\'");
        const lastVisit = p.lastConsultation
            ? new Date(p.lastConsultation).toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'numeric' })
            : null;
        const isActive   = !!p.lastConsultation;
        const isReferred = p.historySummary?.toLowerCase().includes('refer');
        const dotColor   = isReferred ? '#f59e0b' : isActive ? '#22c55e' : '#94a3b8';
        const statusLabel = isReferred ? '🔁 Referred' : isActive ? '✅ Active' : '⏳ No History';
        const summary = p.historySummary && p.historySummary !== 'No history available'
            ? p.historySummary : '';

        return `<div class="patient-card">
            <div class="patient-card-left">
                <div class="patient-card-name">
                    <span class="patient-status-dot" style="background:${dotColor};"></span>
                    ${p.fullName}
                    <span class="patient-id-badge">ID ${p.id}</span>
                    ${p.age ? `<span class="age-badge">Age ${p.age}</span>` : ''}
                </div>
                <div class="patient-meta">
                    ${lastVisit ? `<span>📅 Last visit: ${lastVisit}</span>` : '<span style="color:#94a3b8;">No visits yet</span>'}
                    <span>${statusLabel}</span>
                </div>
                ${summary ? `<div class="patient-summary">${summary}</div>` : ''}
            </div>
            <div class="patient-card-actions">
                <button class="patient-action-btn primary" onclick="prepareConsultation(${p.id}, '${name}')">📝 Notes</button>
                <button class="patient-action-btn" onclick="prepareReferral(${p.id}, '${name}')">🔄 Refer</button>
                <button class="patient-action-btn" onclick="openMDPatientInspector(${p.id}, '${name}')">📋 History</button>
                <button class="patient-action-btn" onclick="openUploadReport(${p.id})">📤 Upload</button>
                <button class="patient-action-btn" onclick="openReports(${p.id})">📁 Reports</button>
            </div>
        </div>`;
    }).join('');
}

function prepareConsultation(patientId, patientName) {
    document.getElementById('consult-patient-id').value = patientId;
    document.getElementById('consult-patient-name').innerText = 'Patient: ' + patientName;
    document.getElementById('consult-notes').value = '';
    document.getElementById('consult-prescription').value = '';
    document.getElementById('consult-report').value = '';
    openModal('add-patient-modal');
}

async function addConsultation() {
    const pId = document.getElementById('consult-patient-id').value;
    const notes = document.getElementById('consult-notes').value;
    const rx = document.getElementById('consult-prescription').value;
    const rep = document.getElementById('consult-report').value;
    if (!notes || !rx) return alert('Diagnosis and Prescription required!');
    try {
        await fetch(`${API_BASE}/doctor/${currentUser.userId}/consultations?patientId=${pId}&notes=${encodeURIComponent(notes)}&prescription=${encodeURIComponent(rx)}&reportsUrl=${encodeURIComponent(rep)}`, { method: 'POST' });
        alert('Clinical record saved!');
        closeModal('add-patient-modal');
        loadDoctorDashboard();
    } catch(e) { alert('Failed.'); }
}

function prepareReferral(patientId, patientName) {
    document.getElementById('ref-patient-id').value = patientId;
    document.getElementById('ref-patient-name').innerText = 'Patient: ' + patientName;
    document.getElementById('ref-reason').value = '';
    openModal('refer-modal');
}

async function sendReferral() {
    const pId = document.getElementById('ref-patient-id').value;
    const specialty = document.getElementById('ref-specialty').value;
    const reason = document.getElementById('ref-reason').value;
    const urgency = document.getElementById('ref-urgency').value;
    if (!reason) return alert('Reason required.');
    try {
        await fetch(`${API_BASE}/doctor/${currentUser.userId}/referrals`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ patientId: pId, requestedSpecialty: specialty, urgency: urgency, reason: reason })
        });
        alert('Referral sent to MD for approval.');
        closeModal('refer-modal');
    } catch(e) { alert('Failed.'); }
}

// ========================
// PATIENT DASHBOARD
// ========================
let allHistoryData = [];

async function loadPatientDashboard() {
    try {
        const res = await fetch(`${API_BASE}/patient/${currentUser.userId}/history`);
        allHistoryData = await res.json();
        allHistoryData.sort((a, b) => new Date(b.date) - new Date(a.date));
        renderHistoryTable(allHistoryData);
    } catch(e) {
        document.getElementById('history-table-body').innerHTML =
            '<tr><td colspan="5" style="padding:20px;text-align:center;color:var(--danger);">Failed to load history.</td></tr>';
    }

    const aptContainer = document.getElementById('patient-appointments');
    try {
        const tRes = await fetch(`${API_BASE}/patient/${currentUser.userId}/tokens`);
        const tData = await tRes.json();
        aptContainer.innerHTML = '';
        let hasActives = false;
        let blockNewRequests = false;
        tData.forEach(tk => {
            if (tk.status === 'APPROVED') {
                blockNewRequests = true; hasActives = true;
                const btnHtml = renderTimeStatusButton(tk);
                const schedInfo = tk.scheduledTime
                    ? `<small style="color:var(--accent-1);">📅 ${new Date(tk.scheduledTime).toLocaleString([], {dateStyle:'short', timeStyle:'short'})}</small>`
                    : '';
                const icon = tk.type === 'VIDEO' ? '📹' : '💬';
                aptContainer.innerHTML += `<div class="card" style="display:flex;justify-content:space-between;align-items:center;border-left:4px solid var(--success);">
                    <div><h4 style="margin:0;">${icon} Meeting with MD (${tk.type}) — Approved</h4>${schedInfo}</div>
                    <div>${btnHtml}</div>
                </div>`;
            } else if (tk.status === 'REQUESTED') {
                blockNewRequests = true; hasActives = true;
                aptContainer.innerHTML += `<div class="card" style="border-left:4px solid var(--accent-1);">
                    <h4>⏳ ${tk.type} Session — Pending MD Approval</h4>
                    <p>Your request has been sent. Waiting for MD to schedule a time.</p>
                </div>`;
            }
        });
        if (!hasActives) {
            // Show "No active appointments" with Request MD Token button inline
            aptContainer.innerHTML = `<div style="display:flex;justify-content:space-between;align-items:center;padding:4px 0;">
                <p class="text-muted">No active appointments.</p>
                <button id="patient-request-token-btn" class="submit-btn" style="width:auto;padding:9px 18px;" onclick="openModal('token-modal')">💬 Request MD Token</button>
            </div>`;
        } else {
            // Add token button below active cards if not blocked
            const reqBtn = document.getElementById('patient-request-token-btn');
            if (reqBtn) {
                if (blockNewRequests) {
                    reqBtn.disabled = true; reqBtn.innerText = 'Request MD Token (Pending)'; reqBtn.classList.add('outline');
                } else {
                    reqBtn.disabled = false; reqBtn.innerText = '💬 Request MD Token'; reqBtn.classList.remove('outline');
                }
            }
        }
    } catch(e) {}
}

function renderHistoryTable(data) {
    const tbody = document.getElementById('history-table-body');
    if (!data.length) {
        tbody.innerHTML = '<tr><td colspan="5" style="padding:32px;text-align:center;color:var(--text-muted);font-size:0.92rem;">No medical history available.</td></tr>';
        return;
    }
    tbody.innerHTML = data.map((item, i) => {
        const date = new Date(item.date).toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'numeric' });
        const diagnosis = item.notes || '—';
        const rx = item.prescription || '—';
        const status = item.referralInfo ? '🔁 Referred' : '✅ Completed';
        const reportBtn = item.reportsUrl
            ? `<button onclick="viewHistoryReport(${JSON.stringify(item).replace(/"/g,'&quot;')})"
                style="background:var(--primary-light);border:1.5px solid var(--primary);color:var(--primary);padding:4px 10px;border-radius:7px;font-size:0.78rem;font-weight:600;cursor:pointer;white-space:nowrap;">
                📎 View
               </button>`
            : '';
        const rowBg = i % 2 === 0 ? '#ffffff' : '#f8fafc';
        return `<tr style="background:${rowBg};transition:background 0.15s;" onmouseover="this.style.background='#eff6ff'" onmouseout="this.style.background='${rowBg}'">
            <td style="padding:12px 14px;font-size:0.85rem;white-space:nowrap;color:var(--text-muted);border-bottom:1px solid var(--border);">${date}</td>
            <td style="padding:12px 14px;font-size:0.85rem;font-weight:600;border-bottom:1px solid var(--border);">Dr. ${item.doctorName}</td>
            <td style="padding:12px 14px;font-size:0.85rem;max-width:220px;word-wrap:break-word;border-bottom:1px solid var(--border);">${diagnosis}</td>
            <td style="padding:12px 14px;font-size:0.85rem;max-width:180px;word-wrap:break-word;color:#0891b2;border-bottom:1px solid var(--border);">${rx}</td>
            <td style="padding:12px 14px;font-size:0.82rem;border-bottom:1px solid var(--border);">${status} ${reportBtn}</td>
        </tr>`;
    }).join('');
}

function applyHistoryFilters() {
    const doctor    = (document.getElementById('filter-doctor')?.value || '').toLowerCase();
    const diagnosis = (document.getElementById('filter-diagnosis')?.value || '').toLowerCase();
    const from      = document.getElementById('filter-from')?.value;
    const sort      = document.getElementById('filter-sort')?.value || 'latest';

    let filtered = allHistoryData.filter(item => {
        const matchDoctor    = !doctor    || item.doctorName.toLowerCase().includes(doctor);
        const matchDiagnosis = !diagnosis || (item.notes || '').toLowerCase().includes(diagnosis);
        const itemDate = new Date(item.date);
        const matchFrom = !from || itemDate >= new Date(from);
        return matchDoctor && matchDiagnosis && matchFrom;
    });

    if (sort === 'latest')       filtered.sort((a, b) => new Date(b.date) - new Date(a.date));
    else if (sort === 'oldest')  filtered.sort((a, b) => new Date(a.date) - new Date(b.date));
    else if (sort === 'doctor')  filtered.sort((a, b) => a.doctorName.localeCompare(b.doctorName));

    renderHistoryTable(filtered);
}

function clearHistoryFilters() {
    ['filter-doctor','filter-diagnosis','filter-from'].forEach(id => {
        const el = document.getElementById(id); if (el) el.value = '';
    });
    const sort = document.getElementById('filter-sort');
    if (sort) sort.value = 'latest';
    renderHistoryTable(allHistoryData);
}

function exportHistoryPDF() {
    if (!allHistoryData.length) return alert('No history to export.');
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF({ orientation: 'landscape' });

    doc.setFontSize(16); doc.setTextColor(59, 130, 246);
    doc.text('Tele Patient System', 14, 16);
    doc.setFontSize(11); doc.setTextColor(15, 23, 42);
    doc.text('Patient: ' + (currentUser?.fullName || 'N/A'), 14, 24);
    doc.setFontSize(9); doc.setTextColor(100, 116, 139);
    doc.text('Report Generated: ' + new Date().toLocaleString(), 14, 30);

    const doctor    = (document.getElementById('filter-doctor')?.value || '').toLowerCase();
    const diagnosis = (document.getElementById('filter-diagnosis')?.value || '').toLowerCase();
    const from      = document.getElementById('filter-from')?.value;
    const sort      = document.getElementById('filter-sort')?.value || 'latest';

    let data = allHistoryData.filter(item => {
        const matchDoctor    = !doctor    || item.doctorName.toLowerCase().includes(doctor);
        const matchDiagnosis = !diagnosis || (item.notes || '').toLowerCase().includes(diagnosis);
        const matchFrom = !from || new Date(item.date) >= new Date(from);
        return matchDoctor && matchDiagnosis && matchFrom;
    });
    if (sort === 'latest')      data.sort((a, b) => new Date(b.date) - new Date(a.date));
    else if (sort === 'oldest') data.sort((a, b) => new Date(a.date) - new Date(b.date));
    else if (sort === 'doctor') data.sort((a, b) => a.doctorName.localeCompare(b.doctorName));

    const rows = data.map(item => [
        new Date(item.date).toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'numeric' }),
        'Dr. ' + item.doctorName,
        item.notes || '—',
        item.prescription || '—',
        item.referralInfo ? 'Referred' : 'Completed'
    ]);

    doc.autoTable({
        startY: 36,
        head: [['Date', 'Doctor', 'Diagnosis', 'Prescription (Rx)', 'Status']],
        body: rows,
        styles: { fontSize: 9, cellPadding: 5, overflow: 'linebreak' },
        headStyles: { fillColor: [59, 130, 246], textColor: 255, fontStyle: 'bold' },
        alternateRowStyles: { fillColor: [248, 250, 252] },
        columnStyles: {
            0: { cellWidth: 30 },
            1: { cellWidth: 45 },
            2: { cellWidth: 80 },
            3: { cellWidth: 70 },
            4: { cellWidth: 32 }
        },
        margin: { left: 14, right: 14 }
    });

    doc.save(`medical_history_${(currentUser?.fullName || 'patient').replace(/\s/g,'_')}.pdf`);
}

// ========================
// EMERGENCY CALL
// ========================
async function triggerEmergencyCall(level) {
    closeModal('emergency-modal');
    const fab = document.getElementById('emergency-fab').querySelector('button');
    fab.disabled = true;
    fab.innerText = '⏳';
    try {
        const res = await fetch(`${API_BASE}/patient/${currentUser.userId}/emergency?level=${level}`, { method: 'POST' });
        const msg = await res.text();
        // Play alert sound
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain); gain.connect(ctx.destination);
            osc.frequency.value = level === 'CRITICAL' ? 880 : level === 'URGENT' ? 660 : 440;
            osc.start(); gain.gain.setValueAtTime(0.3, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.8);
            osc.stop(ctx.currentTime + 0.8);
        } catch(e) {}
        fab.innerText = '✅';
        fab.style.background = 'linear-gradient(135deg,#22c55e,#16a34a)';
        fab.style.animation = 'none';
        const levelLabels = { CRITICAL: '🔴 Critical', URGENT: '🟡 Urgent', NORMAL: '🟢 Normal' };
        alert(`${levelLabels[level]} alert sent!\n\n${msg}`);
        // Reset button back to ready state
        fab.disabled = false;
        fab.innerText = '🚨';
        fab.style.background = 'linear-gradient(135deg,#ef4444,#b91c1c)';
        fab.style.animation = 'pulse-red 2s infinite';
    } catch(e) {
        alert('Failed to send alert. Please call reception directly.');
        fab.disabled = false;
        fab.innerText = '🚨';
        fab.style.background = 'linear-gradient(135deg,#ef4444,#b91c1c)';
        fab.style.animation = 'pulse-red 2s infinite';
    }
}

async function loadMDEmergencyQueue() {
    const container = document.getElementById('md-emergency-queue');
    const badge = document.getElementById('emergency-badge');
    if (!container) return;
    try {
        const res = await fetch(`${API_BASE}/md/emergencies`);
        if (!res.ok) return;
        const data = await res.json();
        if (!data.length) {
            container.innerHTML = '<p class="text-muted">No active emergencies.</p>';
            badge.style.display = 'none';
            return;
        }
        badge.style.display = 'inline-block';
        // Play beep for new emergencies
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain); gain.connect(ctx.destination);
            osc.frequency.value = 880;
            osc.start(); gain.gain.setValueAtTime(0.2, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.5);
            osc.stop(ctx.currentTime + 0.5);
        } catch(e) {}
        const levelColors = { CRITICAL: '#ef4444', URGENT: '#f59e0b', NORMAL: '#22c55e' };
        const levelLabels = { CRITICAL: '🔴 CRITICAL', URGENT: '🟡 URGENT', NORMAL: '🟢 NORMAL' };
        container.innerHTML = data.map(e => `
            <div class="emergency-card" style="border-left:4px solid ${levelColors[e.level] || '#ef4444'};">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <span style="font-weight:700;color:${levelColors[e.level] || '#ef4444'};">${levelLabels[e.level] || '🔴 CRITICAL'}</span>
                        <span style="margin-left:10px;font-weight:600;">${e.patientName}</span>
                        <span class="text-muted" style="font-size:0.8rem;margin-left:8px;">${new Date(e.alertTime).toLocaleTimeString()}</span>
                    </div>
                    <button onclick="acknowledgeEmergency(${e.id})" style="padding:6px 14px;border-radius:8px;border:1px solid #22c55e;background:rgba(34,197,94,0.15);color:#22c55e;font-weight:600;font-size:0.82rem;cursor:pointer;">
                        ✓ Acknowledge
                    </button>
                </div>
            </div>`).join('');
    } catch(e) {}
}

async function acknowledgeEmergency(id) {
    try {
        await fetch(`${API_BASE}/md/emergencies/${id}/acknowledge`, { method: 'PUT' });
        loadMDEmergencyQueue();
    } catch(e) {}
}


async function requestToken() {
    const type = document.getElementById('token-type').value;
    try {
        let mdId = 1;
        try {
            const mdRes = await fetch(`${API_BASE}/md/admin-id`);
            if (mdRes.ok) mdId = await mdRes.json();
        } catch(e) {}
        const res = await fetch(`${API_BASE}/patient/tokens`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ patientId: currentUser.userId, mdId: mdId, type: type })
        });
        if (!res.ok) throw new Error('Server rejected token request');
        alert('✅ Token request sent to MD successfully!');
        document.getElementById('token-modal').classList.remove('show');
        loadPatientDashboard();
    } catch(e) { alert('Failed: ' + e.message); }
}

// ========================
// SHARED
// ========================
async function loadSocialFeed() {
    try {
        const res = await fetch(`${API_BASE}/shared/social`);
        const data = await res.json();
        const feed = document.getElementById('social-feed');
        feed.innerHTML = '';
        if (data.length === 0) { feed.innerHTML = '<p class="text-muted">No broadcasts yet.</p>'; return; }
        data.forEach(post => {
            let mediaHtml = '';
            if (post.mediaUrl) {
                if (post.mediaUrl.includes('youtube.com') || post.mediaUrl.includes('youtu.be')) {
                    const vid = post.mediaUrl.includes('v=') ? post.mediaUrl.split('v=')[1].split('&')[0] : post.mediaUrl.split('/').pop();
                    mediaHtml = `<iframe width="100%" height="180" src="https://www.youtube.com/embed/${vid}" frameborder="0" allowfullscreen></iframe>`;
                } else if (post.mediaUrl.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
                    mediaHtml = `<img src="${post.mediaUrl}" style="width:100%;border-radius:8px;margin-top:8px;"/>`;
                } else {
                    mediaHtml = `<a href="${post.mediaUrl}" target="_blank" style="color:var(--accent-1);display:block;margin-top:6px;">🔗 ${post.mediaUrl}</a>`;
                }
            }
            const authorId = post.author?.id;
            const canDelete = currentUser && (currentUser.role === 'MAIN_DOCTOR' || currentUser.userId === authorId);
            const deleteBtn = canDelete
                ? `<button onclick="deleteSocialPost(${post.id},this)" title="Delete"
                    style="background:none;border:none;cursor:pointer;color:#ef4444;font-size:1rem;padding:4px 6px;border-radius:6px;line-height:1;"
                    onmouseover="this.style.background='#fef2f2'" onmouseout="this.style.background='none'">🗑</button>`
                : '';
            feed.innerHTML += `<div class="social-post" id="social-post-${post.id}" style="position:relative;">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <small style="color:var(--primary);">${new Date(post.postedAt).toLocaleString()}</small>
                    ${deleteBtn}
                </div>
                <h4>${post.title}</h4>
                <p>${post.content}</p>
                ${mediaHtml}
            </div>`;
        });
    } catch(e) {}
}

async function deleteSocialPost(postId, btn) {
    if (!confirm('Are you sure you want to delete this post?')) return;
    btn.disabled = true;
    try {
        const res = await fetch(`${API_BASE}/shared/social/${postId}?requesterId=${currentUser.userId}`, { method: 'DELETE' });
        if (!res.ok) throw new Error(await res.text());
        const el = document.getElementById(`social-post-${postId}`);
        if (el) { el.style.opacity = '0'; el.style.transition = 'opacity 0.3s'; setTimeout(() => el.remove(), 300); }
    } catch(e) { alert('Failed: ' + e.message); btn.disabled = false; }
}

// FIX 5 & 6: Launchpad visible for all roles, MD sees submissions, others see submit form
async function handleLaunchpadClick() {
    if (currentUser.role === 'MAIN_DOCTOR') {
        openModal('md-launchpad-modal');
        const feed = document.getElementById('md-launchpad-feed');
        feed.innerHTML = 'Loading...';
        try {
            const res = await fetch(`${API_BASE}/md/launchpad`);
            const data = await res.json();
            feed.innerHTML = '';
            if (data.length === 0) { feed.innerHTML = '<p class="text-muted">No ideas received.</p>'; return; }
            data.forEach(idea => {
                feed.innerHTML += `<div class="card" id="idea-card-${idea.id}" style="margin-bottom:10px;position:relative;">
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <small style="color:var(--text-muted);">Domain: ${idea.domain || '—'}</small>
                        <button onclick="deleteLaunchpadIdea(${idea.id},this)" title="Delete"
                            style="background:none;border:none;cursor:pointer;color:#ef4444;font-size:1rem;padding:4px 6px;border-radius:6px;line-height:1;"
                            onmouseover="this.style.background='#fef2f2'" onmouseout="this.style.background='none'">🗑</button>
                    </div>
                    <h4 style="margin:5px 0;">${idea.ideaTitle}</h4>
                    <p>${idea.description}</p>
                    <div style="background:var(--bg-secondary);padding:10px;border-radius:8px;margin-top:5px;">
                        <small style="display:block;color:var(--primary);">Contact: ${idea.submitterEmail}</small>
                        <small style="display:block;color:var(--text-muted);">Info: ${idea.contactInfo || 'N/A'}</small>
                    </div>
                </div>`;
            });
        } catch(e) { feed.innerHTML = '<p class="text-danger">Failed.</p>'; }
    } else {
        openModal('launchpad-modal');
    }
}

async function deleteLaunchpadIdea(ideaId, btn) {
    if (!confirm('Are you sure you want to delete this idea?')) return;
    btn.disabled = true;
    try {
        const res = await fetch(`${API_BASE}/shared/launchpad/${ideaId}?requesterId=${currentUser.userId}`, { method: 'DELETE' });
        if (!res.ok) throw new Error(await res.text());
        const el = document.getElementById(`idea-card-${ideaId}`);
        if (el) { el.style.opacity = '0'; el.style.transition = 'opacity 0.3s'; setTimeout(() => el.remove(), 300); }
    } catch(e) { alert('Failed: ' + e.message); btn.disabled = false; }
}

async function submitLaunchpad() {
    const title = document.getElementById('lp-title').value;
    const desc = document.getElementById('lp-desc').value;
    const domain = document.getElementById('lp-domain').value;
    if (!title || !desc) return alert('Title and Description are required!');
    const pLoad = {
        submitterId: currentUser.userId,
        ideaTitle: title,
        description: desc,
        domain: domain,
        contactInfo: document.getElementById('lp-contact') ? document.getElementById('lp-contact').value : ''
    };
    try {
        const res = await fetch(`${API_BASE}/shared/launchpad`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(pLoad)
        });
        if (!res.ok) throw new Error('Server error');
        alert('✅ Idea submitted to MD LaunchPad!');
        document.getElementById('launchpad-modal').classList.remove('show');
        ['lp-title','lp-desc','lp-domain','lp-contact'].forEach(id => { const el = document.getElementById(id); if(el) el.value=''; });
    } catch(e) { alert('Failed: ' + e.message); }
}

function openModal(id) { document.getElementById(id).classList.add('show'); }
function closeModal(id) {
    document.getElementById(id).classList.remove('show');
    document.querySelectorAll(`#${id} input:not([type=hidden]), #${id} textarea`).forEach(el => { el.value = ''; });
}

function toggleDropdown(id) {
    const menu = document.getElementById(id);
    const isOpen = menu.classList.contains('open');
    document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
    if (!isOpen) menu.classList.add('open');
}
document.addEventListener('click', (e) => {
    if (!e.target.closest('.dropdown')) document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
});

// ========================
// NOTIFICATIONS
// ========================
let notifPanelOpen = false;

async function loadNotifications() {
    if (!currentUser) return;
    try {
        const res = await fetch(`${API_BASE}/notifications/${currentUser.userId}`);
        const data = await res.json();
        const unread = data.filter(n => !n.read).length;
        const badge = document.getElementById('notif-badge');
        if (badge) {
            badge.style.display = unread > 0 ? 'flex' : 'none';
            badge.innerText = unread > 9 ? '9+' : unread;
        }
        const list = document.getElementById('notif-list');
        if (!list) return;
        if (!data.length) {
            list.innerHTML = '<p class="text-muted" style="padding:16px;text-align:center;font-size:0.88rem;">No notifications yet.</p>';
            return;
        }
        const icons = { REPORT:'📋', PRESCRIPTION:'💊', APPOINTMENT:'📅', CHAT:'💬', EMERGENCY:'🚨', GENERAL:'📢' };
        const colors = { HIGH:'#fef2f2', MEDIUM:'#fffbeb', LOW:'#f8fafc' };
        const dotColors = { HIGH:'#ef4444', MEDIUM:'#f59e0b', LOW:'#3b82f6' };
        list.innerHTML = data.map(n => `
            <div onclick="markNotifRead(${n.id}, this)" style="padding:12px 16px;cursor:pointer;border-bottom:1px solid var(--border);background:${n.read ? 'white' : colors[n.priority] || '#f8fafc'};transition:background 0.15s;"
                onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='${n.read ? 'white' : colors[n.priority] || '#f8fafc'}'">
                <div style="display:flex;align-items:flex-start;gap:10px;">
                    <span style="font-size:1.1rem;flex-shrink:0;">${icons[n.type] || '🔔'}</span>
                    <div style="flex:1;min-width:0;">
                        <div style="font-size:0.85rem;font-weight:${n.read ? '400' : '600'};color:var(--text-main);line-height:1.4;">${n.message}</div>
                        <div style="font-size:0.75rem;color:var(--text-muted);margin-top:3px;">${timeAgo(n.createdAt)}</div>
                    </div>
                    ${!n.read ? `<span style="width:8px;height:8px;border-radius:50%;background:${dotColors[n.priority] || '#3b82f6'};flex-shrink:0;margin-top:4px;"></span>` : ''}
                </div>
            </div>`).join('');
    } catch(e) {}
}

function toggleNotifPanel() {
    const panel = document.getElementById('notif-panel');
    if (!panel) return;
    notifPanelOpen = !notifPanelOpen;
    panel.style.display = notifPanelOpen ? 'block' : 'none';
    if (notifPanelOpen) loadNotifications();
}

async function markNotifRead(id, el) {
    try {
        await fetch(`${API_BASE}/notifications/${id}/read`, { method: 'PUT' });
        if (el) el.style.background = 'white';
        loadNotifications();
    } catch(e) {}
}

async function markAllNotifRead() {
    if (!currentUser) return;
    try {
        await fetch(`${API_BASE}/notifications/${currentUser.userId}/read-all`, { method: 'PUT' });
        loadNotifications();
    } catch(e) {}
}

function timeAgo(dateStr) {
    const diff = Math.floor((Date.now() - new Date(dateStr)) / 1000);
    if (diff < 60) return 'just now';
    if (diff < 3600) return Math.floor(diff/60) + ' min ago';
    if (diff < 86400) return Math.floor(diff/3600) + ' hr ago';
    return Math.floor(diff/86400) + ' day(s) ago';
}

// Close notif panel on outside click
document.addEventListener('click', (e) => {
    const wrap = document.getElementById('notif-wrap');
    if (wrap && !wrap.contains(e.target) && notifPanelOpen) {
        document.getElementById('notif-panel').style.display = 'none';
        notifPanelOpen = false;
    }
});

// ========================
// ADD PATIENT (Doctor)
// ========================
async function submitAddPatient() {
    const name  = document.getElementById('ap-name').value.trim();
    const email = document.getElementById('ap-email').value.trim();
    const age   = document.getElementById('ap-age').value;
    const errEl = document.getElementById('ap-error');
    errEl.innerText = '';
    if (!name) return (errEl.innerText = 'Full name is required.');
    if (!email) return (errEl.innerText = 'Email is required.');
    try {
        const res = await fetch(
            `${API_BASE}/doctor/add-patient?doctorId=${currentUser.userId}${age ? '&age=' + age : ''}`,
            { method: 'POST', headers: {'Content-Type': 'application/json'},
              body: JSON.stringify({ fullName: name, email: email, password: 'temp@123' }) }
        );
        if (!res.ok) {
            const err = await res.json().catch(() => ({}));
            throw new Error(err.email || err.fullName || 'Failed to add patient');
        }
        alert(`✅ Patient "${name}" added successfully! Default password: temp@123`);
        closeModal('add-patient-doctor-modal');
        loadDoctorDashboard();
    } catch(e) { errEl.innerText = e.message; }
}

// ========================
// FILE UPLOAD
// ========================
function handleFileSelect() {
    const file = document.getElementById('consult-report-file').files[0];
    const status = document.getElementById('upload-status');
    if (!file) return;
    const reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('consult-report').value = e.target.result;
        status.innerText = 'File loaded: ' + file.name + ' (' + (file.size/1024).toFixed(1) + ' KB)';
    };
    reader.readAsDataURL(file);
}

// ========================
// FINANCIAL RECORDS
// ========================
async function addFinancialRecord() {
    const type = document.getElementById('finance-type').value;
    const amount = document.getElementById('finance-amount').value;
    const desc = document.getElementById('finance-desc').value;
    if (!amount || amount <= 0) return alert('Enter a valid amount.');
    if (!desc) return alert('Enter a description.');
    try {
        await fetch(`${API_BASE}/md/finance`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ type, amount: parseFloat(amount), description: desc })
        });
    } catch(e) {}
    alert('Financial record added! Dashboard updated.');
    closeModal('finance-modal');
    loadMDDashboard();
}

// ========================
// MEDICAL REPORTS
// ========================
let activeReportForChat = null;

async function openReports(patientId) {
    openModal('reports-modal');
    const container = document.getElementById('reports-list');
    container.innerHTML = '<p class="text-muted">Loading...</p>';
    try {
        const res = await fetch(`${API_BASE}/reports/${patientId}`);
        const data = await res.json();
        if (!data.length) {
            container.innerHTML = '<p class="text-muted" style="padding:10px;">No reports found.</p>';
            return;
        }
        const typeIcon = { PDF: '📄', IMAGE: '🖼', TEXT: '📝' };
        container.innerHTML = data.map(r => `
            <div class="card" style="margin-bottom:12px;border-left:4px solid var(--primary);">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:8px;">
                    <div>
                        <div style="font-weight:700;font-size:1rem;">${typeIcon[r.reportType] || '📄'} ${r.reportName}</div>
                        <div class="text-muted" style="font-size:0.8rem;margin-top:4px;">
                            Dr. ${r.doctorName} &nbsp;·&nbsp; ${new Date(r.uploadedAt).toLocaleDateString()}
                            &nbsp;·&nbsp; <span style="background:var(--primary-light);color:var(--primary);padding:2px 8px;border-radius:8px;font-size:0.75rem;font-weight:600;">${r.reportType}</span>
                        </div>
                        ${r.notes ? `<div style="font-size:0.82rem;color:var(--text-muted);margin-top:4px;">${r.notes}</div>` : ''}
                    </div>
                    <div style="display:flex;gap:8px;flex-wrap:wrap;">
                        <button class="submit-btn outline" style="width:auto;padding:6px 12px;font-size:0.82rem;" onclick="viewReport(${JSON.stringify(r).replace(/"/g,'&quot;')})">👁 View</button>
                    </div>
                </div>
            </div>`).join('');
    } catch(e) {
        container.innerHTML = '<p style="color:var(--danger);">Failed to load reports.</p>';
    }
}

// Shared report viewer — used by both uploaded reports and history entries
function openReportViewer({ title, meta, diagnosis, prescription, referralInfo, fileUrl, fileType, reportObj }) {
    document.getElementById('report-viewer-title').innerText = title || 'Report';

    // Meta row (doctor, date, type)
    const metaEl = document.getElementById('report-viewer-meta');
    metaEl.innerHTML = meta || '';

    // Clinical info (diagnosis / rx)
    const clinicalEl = document.getElementById('report-viewer-clinical');
    if (diagnosis || prescription) {
        clinicalEl.style.display = 'block';
        clinicalEl.innerHTML = `
            ${diagnosis ? `<div style="margin-bottom:10px;padding:12px;background:var(--bg-secondary);border-radius:10px;border-left:3px solid var(--primary);">
                <div style="font-size:0.72rem;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.5px;margin-bottom:4px;">📋 Diagnosis</div>
                <div style="font-size:0.9rem;color:var(--text-main);">${diagnosis}</div>
            </div>` : ''}
            ${prescription ? `<div style="padding:12px;background:#f0fdf4;border-radius:10px;border-left:3px solid var(--green);">
                <div style="font-size:0.72rem;font-weight:700;color:var(--green);text-transform:uppercase;letter-spacing:0.5px;margin-bottom:4px;">💊 Prescription</div>
                <div style="font-size:0.9rem;color:var(--text-main);">${prescription}</div>
            </div>` : ''}
            ${referralInfo ? `<p style="margin-top:8px;font-size:0.82rem;color:var(--text-muted);">🔁 ${referralInfo}</p>` : ''}`;
    } else {
        clinicalEl.style.display = 'none';
        clinicalEl.innerHTML = '';
    }

    // File preview
    const content = document.getElementById('report-viewer-content');
    if (!fileUrl) {
        content.innerHTML = '<p class="text-muted" style="padding:16px;text-align:center;">No file attached to this record.</p>';
    } else if (fileType === 'IMAGE' || fileUrl.match(/\.(jpg|jpeg|png|gif|webp)$/i) || fileUrl.startsWith('data:image')) {
        content.innerHTML = `<img src="${fileUrl}" style="width:100%;border-radius:10px;max-height:480px;object-fit:contain;"
            onerror="this.outerHTML='<p style=color:var(--danger);padding:12px>Image could not be loaded.</p>'">`;
    } else if (fileType === 'PDF' || fileUrl.includes('.pdf') || fileUrl.startsWith('data:application/pdf')) {
        content.innerHTML = `<iframe src="${fileUrl}" style="width:100%;height:460px;border-radius:10px;border:1px solid var(--border);"></iframe>
            <p style="margin-top:8px;font-size:0.8rem;color:var(--text-muted);">PDF not loading? <a href="${fileUrl}" target="_blank" style="color:var(--primary);">Open in new tab</a></p>`;
    } else {
        content.innerHTML = `<div style="background:var(--bg-secondary);padding:16px;border-radius:10px;white-space:pre-wrap;font-size:0.9rem;line-height:1.6;">${fileUrl}</div>`;
    }

    // Chat button — only when active chat session
    const chatBtn = document.getElementById('report-chat-btn');
    if (reportObj && activeChatTokenId) {
        activeReportForChat = reportObj;
        chatBtn.style.display = 'flex';
    } else {
        chatBtn.style.display = 'none';
    }

    openModal('report-viewer-modal');
}

// Called from uploaded reports list
function viewReport(report) {
    activeReportForChat = report;
    const typeIcon = report.reportType === 'PDF' ? '📄' : report.reportType === 'IMAGE' ? '🖼' : '📝';
    openReportViewer({
        title: `${typeIcon} ${report.reportName}`,
        meta: `<span>👨‍⚕️ Dr. ${report.doctorName}</span><span>📅 ${new Date(report.uploadedAt).toLocaleDateString('en-IN',{day:'2-digit',month:'short',year:'numeric'})}</span><span style="background:var(--primary-light);color:var(--primary);padding:2px 8px;border-radius:8px;font-size:0.78rem;font-weight:600;">${report.reportType}</span>`,
        diagnosis: report.notes || null,
        fileUrl: report.fileUrl,
        fileType: report.reportType,
        reportObj: report
    });
}

// Called from clinical history "📎 View Report"
function viewHistoryReport(h) {
    openReportViewer({
        title: `📋 Clinical Record — Dr. ${h.doctorName}`,
        meta: `<span>👨‍⚕️ Dr. ${h.doctorName}</span><span>📅 ${new Date(h.date).toLocaleDateString('en-IN',{day:'2-digit',month:'short',year:'numeric'})}</span>`,
        diagnosis: h.notes || null,
        prescription: h.prescription || null,
        referralInfo: h.referralInfo || null,
        fileUrl: h.reportsUrl || null,
        fileType: h.reportsUrl?.includes('.pdf') ? 'PDF' : h.reportsUrl?.match(/\.(jpg|jpeg|png)$/i) ? 'IMAGE' : null,
        reportObj: null
    });
}

function downloadReport(report) {
    if (!report.fileUrl) return alert('File not available.');
    const url = report.fileUrl;
    const name = report.reportName || 'report';

    // base64 data URL — convert to blob and download
    if (url.startsWith('data:')) {
        const [meta, base64] = url.split(',');
        const mime = meta.match(/:(.*?);/)[1];
        const binary = atob(base64);
        const arr = new Uint8Array(binary.length);
        for (let i = 0; i < binary.length; i++) arr[i] = binary.charCodeAt(i);
        const blob = new Blob([arr], { type: mime });
        const ext = mime.includes('pdf') ? '.pdf' : mime.includes('png') ? '.png' : mime.includes('jpeg') ? '.jpg' : '';
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = name + ext;
        document.body.appendChild(a); a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(a.href);
    } else {
        // Regular URL — direct download
        const a = document.createElement('a');
        a.href = url;
        a.download = name;
        a.target = '_blank';
        document.body.appendChild(a); a.click();
        document.body.removeChild(a);
    }
}

async function sendReportToChat() {
    if (!activeReportForChat || !activeChatTokenId) return;
    try {
        const res = await fetch(`${API_BASE}/reports/send-to-chat`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                reportId: activeReportForChat.id,
                tokenId: activeChatTokenId,
                senderId: currentUser.userId
            })
        });
        if (!res.ok) throw new Error('Failed');
        alert('✅ Report shared in chat!');
        closeModal('report-viewer-modal');
        pollChatMessages();
    } catch(e) { alert('Failed to send: ' + e.message); }
}

function openUploadReport(patientId) {
    document.getElementById('upload-report-patient-id').value = patientId;
    document.getElementById('upload-report-status').innerText = '';
    openModal('upload-report-modal');
}

function handleReportFileSelect() {
    const file = document.getElementById('upload-report-file').files[0];
    const status = document.getElementById('upload-report-status');
    if (!file) return;
    const reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('upload-report-url').value = e.target.result;
        // Auto-detect type
        if (file.type.includes('pdf')) document.getElementById('upload-report-type').value = 'PDF';
        else if (file.type.includes('image')) document.getElementById('upload-report-type').value = 'IMAGE';
        status.innerText = '✅ File loaded: ' + file.name;
    };
    reader.readAsDataURL(file);
}

async function submitReportUpload() {
    const patientId = document.getElementById('upload-report-patient-id').value;
    const name  = document.getElementById('upload-report-name').value;
    const type  = document.getElementById('upload-report-type').value;
    const url   = document.getElementById('upload-report-url').value;
    const notes = document.getElementById('upload-report-notes').value;
    if (!name) return alert('Enter a report name.');
    if (!url)  return alert('Select a file or enter a URL.');
    try {
        await fetch(`${API_BASE}/reports/upload`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ patientId: parseInt(patientId), doctorId: currentUser.userId, reportName: name, reportType: type, fileUrl: url, notes })
        });
        alert('✅ Report uploaded successfully!');
        closeModal('upload-report-modal');
        loadDoctorDashboard();
    } catch(e) { alert('Failed: ' + e.message); }
}

// ========================
// CHATBOT
// ========================
const chatbotKB = {
    revenue: 'Total Revenue = all money earned by the hospital (consultation fees, procedures, etc). To add: Login as Main Doctor → click "Add Finance Record" → select Revenue → enter amount and description.',
    expense: 'Total Expenses = all money spent (equipment, salaries, medicines). To add: Login as Main Doctor → click "Add Finance Record" → select Expenditure → enter amount.',
    profit: 'Profit/Loss = Total Revenue minus Total Expenses. Positive = profit, Negative = loss. Values update when you add financial records.',
    finance: 'To change revenue/expense values: Login as Main Doctor → click "Add Finance Record" → select type (Revenue or Expenditure) → enter amount and description → click Add Record.',
    chat: 'To start a chat session: 1) Patient clicks "Request MD Token" and selects Chat. 2) Main Doctor approves and schedules a time. 3) Both patient and MD see a "Join Chat" button. 4) Both can chat in the live window.',
    video: 'Video call: Patient requests VIDEO token → MD approves and schedules → both see "Join Video Call" button → camera opens for the session.',
    token: 'Token system: Patient requests token (Chat or Video) → MD approves and sets time → patient joins. MD can freeze or terminate any session.',
    referral: 'Referral flow: Doctor clicks Refer on a patient → fills reason and specialty → request goes to MD pending queue → MD approves and assigns to another doctor.',
    assign: 'To assign a patient to a doctor: Login as Main Doctor → scroll to "Direct Patient Assignment" → select patient and doctor → click Assign Now.',
    role: '3 roles: Main Doctor (admin) has full control. Doctor manages assigned patients. Patient registers themselves and can request consultations.',
    login: 'Default logins: Main Doctor: admin@123 / admin, Doctor: doctor@123 / doctor. Patients self-register. New users from MD get password temp@123.',
    report: 'Download reports from MD dashboard: Revenue Report, Expense Report, Doctor Stats — available as PDF or Excel.',
    launchpad: 'LaunchPad: Doctors and patients submit ideas → fill title, description, domain, contact → submit. Main Doctor views all submissions.',
    social: 'Social Feed: Only Main Doctor can post (text, YouTube links, images). Everyone can view by clicking Social Feed in navbar.',
    password: 'Forgot password: Click Forgot Password on login → enter email → OTP appears in Spring Boot console → enter OTP and new password.',
    emergency: '🚨 Emergency Contacts:\n\n🔴 Hospital Emergency: <a href="tel:108" style="color:#ef4444;font-weight:700;">108</a>\n🚑 Ambulance: <a href="tel:102" style="color:#ef4444;font-weight:700;">102</a>\n🚒 Fire: <a href="tel:101" style="color:#f59e0b;font-weight:700;">101</a>\n👮 Police: <a href="tel:100" style="color:#3b82f6;font-weight:700;">100</a>\n📞 Hospital Counter: <a href="tel:+911234567890" style="color:#22c55e;font-weight:700;">+91 12345 67890</a>\n\nOr use the 🚨 red button (bottom-right) to instantly alert hospital staff.',
    default: 'I can help with: revenue/expenses, chat/video sessions, token requests, referrals, patient assignment, roles, reports, launchpad, social feed, passwords, emergency numbers. What would you like to know?'
};

function toggleChatbot() {
    const box = document.getElementById('chatbot-box');
    box.classList.toggle('hidden');
    if (!box.classList.contains('hidden') && document.getElementById('chatbot-messages').children.length === 0) {
        addBotMsg('Hello! I am TelePatient Assistant. Ask me anything about how this system works.');
    }
}

function addBotMsg(text) {
    const box = document.getElementById('chatbot-messages');
    const div = document.createElement('div');
    div.style.cssText = 'text-align:left;margin-bottom:8px;';
    div.innerHTML = `<div style="display:inline-block;max-width:90%;background:rgba(59,130,246,0.2);padding:10px 14px;border-radius:4px 14px 14px 14px;font-size:0.85rem;line-height:1.5;">${text}</div>`;
    box.appendChild(div);
    box.scrollTop = box.scrollHeight;
}

function addUserMsg(text) {
    const box = document.getElementById('chatbot-messages');
    const div = document.createElement('div');
    div.style.cssText = 'text-align:right;margin-bottom:8px;';
    div.innerHTML = `<div style="display:inline-block;max-width:90%;background:var(--primary);padding:10px 14px;border-radius:14px 4px 14px 14px;font-size:0.85rem;">${text}</div>`;
    box.appendChild(div);
    box.scrollTop = box.scrollHeight;
}

function sendChatbotMessage() {
    const input = document.getElementById('chatbot-input');
    const msg = input.value.trim();
    if (!msg) return;
    input.value = '';
    addUserMsg(msg);
    const lower = msg.toLowerCase();
    let response = chatbotKB.default;
    if (lower.includes('revenue') || lower.includes('income')) response = chatbotKB.revenue;
    else if (lower.includes('expense') || lower.includes('expenditure') || lower.includes('cost')) response = chatbotKB.expense;
    else if (lower.includes('profit') || lower.includes('loss')) response = chatbotKB.profit;
    else if (lower.includes('finance') || lower.includes('money')) response = chatbotKB.finance;
    else if (lower.includes('chat') || lower.includes('message')) response = chatbotKB.chat;
    else if (lower.includes('video') || lower.includes('call') || lower.includes('camera')) response = chatbotKB.video;
    else if (lower.includes('token') || lower.includes('meeting') || lower.includes('request')) response = chatbotKB.token;
    else if (lower.includes('referral') || lower.includes('refer') || lower.includes('transfer')) response = chatbotKB.referral;
    else if (lower.includes('assign') || (lower.includes('patient') && lower.includes('doctor'))) response = chatbotKB.assign;
    else if (lower.includes('role') || lower.includes('promote') || lower.includes('admin')) response = chatbotKB.role;
    else if (lower.includes('login') || (lower.includes('password') && lower.includes('default'))) response = chatbotKB.login;
    else if (lower.includes('report') || lower.includes('download')) response = chatbotKB.report;
    else if (lower.includes('launchpad') || lower.includes('idea')) response = chatbotKB.launchpad;
    else if (lower.includes('social') || lower.includes('post') || lower.includes('feed')) response = chatbotKB.social;
    else if (lower.includes('password') || lower.includes('otp') || lower.includes('forgot')) response = chatbotKB.password;
    else if (lower.includes('emergency') || lower.includes('ambulance') || lower.includes('helpline') || lower.includes('number') || lower.includes('contact') || lower.includes('call') && lower.includes('hospital')) response = chatbotKB.emergency;
    setTimeout(() => addBotMsg(response), 400);
}

