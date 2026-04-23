import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../api/axios';

export default function DoctorPatients() {
  const { user } = useAuth();
  const [patients, setPatients] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    api.get(`/api/doctor/${user.userId}/patients`)
      .then(r => { setPatients(r.data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const addNote = async (patientId) => {
    const notes = prompt('Consultation notes:');
    if (!notes) return;
    const rx = prompt('Prescription (optional):') || '';
    await api.post(`/api/doctor/${user.userId}/consultations?patientId=${patientId}&notes=${encodeURIComponent(notes)}&prescription=${encodeURIComponent(rx)}`);
    setMsg('Consultation saved');
  };

  const refer = async (patientId) => {
    const specialty = prompt('Requested specialty:');
    const urgency = prompt('Urgency (HIGH/MEDIUM/LOW):') || 'MEDIUM';
    const reason = prompt('Reason:');
    if (!specialty || !reason) return;
    await api.post(`/api/doctor/${user.userId}/referrals`, { patientId, requestedSpecialty: specialty, urgency, reason });
    setMsg('Referral submitted to MD');
  };

  const filtered = patients.filter(p => p.fullName?.toLowerCase().includes(search.toLowerCase()));

  if (loading) return <p>Loading patients...</p>;

  return (
    <div>
      <h2 style={styles.heading}>👥 My Patients ({patients.length})</h2>
      {msg && <div style={styles.toast}>{msg}</div>}
      <input style={styles.search} placeholder="Search..." value={search} onChange={e => setSearch(e.target.value)} />
      {filtered.map(p => (
        <div key={p.id} style={styles.card}>
          <div>
            <strong style={{ fontSize: 16 }}>{p.fullName}</strong>
            <p style={styles.meta}>Age: {p.age ?? '—'} · Last visit: {p.lastConsultation ? new Date(p.lastConsultation).toLocaleDateString() : 'Never'}</p>
            <p style={styles.history}>{p.historySummary}</p>
          </div>
          <div style={styles.actions}>
            <button style={styles.btn} onClick={() => addNote(p.id)}>📝 Add Note</button>
            <button style={{ ...styles.btn, background: '#e65100' }} onClick={() => refer(p.id)}>🔁 Refer</button>
          </div>
        </div>
      ))}
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 20px', color: '#1a237e', fontSize: 24 },
  toast: { background: '#e8f5e9', color: '#2e7d32', padding: '10px 16px', borderRadius: 8, marginBottom: 16, fontSize: 14 },
  search: { width: '100%', padding: '10px 14px', border: '1.5px solid #ddd', borderRadius: 8, fontSize: 14, marginBottom: 16, boxSizing: 'border-box' },
  card: { background: '#fff', borderRadius: 12, padding: '16px 20px', marginBottom: 12, boxShadow: '0 2px 10px rgba(0,0,0,0.07)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' },
  meta: { margin: '4px 0', fontSize: 13, color: '#888' },
  history: { margin: 0, fontSize: 13, color: '#555' },
  actions: { display: 'flex', gap: 8 },
  btn: { background: '#1565c0', color: '#fff', border: 'none', borderRadius: 6, padding: '8px 14px', cursor: 'pointer', fontSize: 13 },
};
