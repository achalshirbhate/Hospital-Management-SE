import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../api/axios';

const STATUS_COLOR = { REQUESTED: '#e65100', APPROVED: '#2e7d32', REJECTED: '#c62828', COMPLETED: '#555' };

export default function PatientAppointments() {
  const { user } = useAuth();
  const [tokens, setTokens] = useState([]);
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState('');

  const load = () => api.get(`/api/patient/${user.userId}/tokens`)
    .then(r => { setTokens(r.data); setLoading(false); }).catch(() => setLoading(false));
  useEffect(load, []);

  const request = async (type) => {
    const mdId = await api.get('/api/md/admin-id').then(r => r.data);
    await api.post('/api/patient/tokens', { patientId: user.userId, mdId, type });
    setMsg(`${type} session requested`); load();
  };

  const triggerEmergency = async () => {
    const level = prompt('Emergency level (CRITICAL / URGENT / NORMAL):', 'CRITICAL');
    if (!level) return;
    await api.post(`/api/patient/${user.userId}/emergency?level=${level}`);
    setMsg('🚨 Emergency alert sent!');
  };

  if (loading) return <p>Loading appointments...</p>;

  return (
    <div>
      <h2 style={styles.heading}>📅 My Appointments</h2>
      {msg && <div style={styles.toast}>{msg}</div>}
      <div style={styles.actions}>
        <button style={styles.btn} onClick={() => request('CHAT')}>💬 Request Chat</button>
        <button style={styles.btn} onClick={() => request('VIDEO_CALL')}>📹 Request Video</button>
        <button style={{ ...styles.btn, background: '#c62828' }} onClick={triggerEmergency}>🚨 Emergency</button>
      </div>
      {tokens.length === 0
        ? <p style={{ color: '#aaa' }}>No appointments yet</p>
        : tokens.map(t => (
          <div key={t.id} style={styles.card}>
            <div>
              <strong>{t.type}</strong>
              <p style={styles.meta}>Requested: {t.requestedAt ? new Date(t.requestedAt).toLocaleString() : '—'}</p>
              {t.scheduledTime && <p style={styles.meta}>Scheduled: {t.scheduledTime}</p>}
            </div>
            <span style={{ ...styles.badge, background: STATUS_COLOR[t.status] || '#888' }}>{t.status}</span>
          </div>
        ))
      }
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 20px', color: '#1a237e', fontSize: 24 },
  toast: { background: '#e8f5e9', color: '#2e7d32', padding: '10px 16px', borderRadius: 8, marginBottom: 16, fontSize: 14 },
  actions: { display: 'flex', gap: 10, marginBottom: 20, flexWrap: 'wrap' },
  btn: { background: '#1565c0', color: '#fff', border: 'none', borderRadius: 8, padding: '10px 18px', cursor: 'pointer', fontSize: 14, fontWeight: 600 },
  card: { background: '#fff', borderRadius: 12, padding: '16px 20px', marginBottom: 12, boxShadow: '0 2px 10px rgba(0,0,0,0.07)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  meta: { margin: '4px 0', fontSize: 13, color: '#888' },
  badge: { color: '#fff', padding: '4px 12px', borderRadius: 20, fontSize: 12, fontWeight: 700 },
};
