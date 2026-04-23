import { useEffect, useState } from 'react';
import api from '../../api/axios';

export default function Queues() {
  const [queues, setQueues] = useState({ referrals: [], tokens: [] });
  const [doctors, setDoctors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState('');

  const load = () => {
    Promise.all([api.get('/api/md/queues'), api.get('/api/md/doctors')])
      .then(([q, d]) => { setQueues(q.data); setDoctors(d.data); setLoading(false); })
      .catch(() => setLoading(false));
  };
  useEffect(load, []);

  const processToken = async (id, approve) => {
    const time = approve ? prompt('Scheduled time (e.g. 2025-05-01 10:00)', '') : null;
    await api.put(`/api/md/tokens/${id}?approve=${approve}${time ? `&scheduledTime=${encodeURIComponent(time)}` : ''}`);
    setMsg(`Token ${approve ? 'approved' : 'rejected'}`); load();
  };

  const processReferral = async (id, approve) => {
    let url = `/api/md/referrals/${id}/assign?approve=${approve}`;
    if (approve) {
      const docId = prompt('Enter Doctor ID to assign:');
      if (docId) url += `&assignedDoctorId=${docId}`;
    }
    await api.put(url);
    setMsg(`Referral ${approve ? 'approved' : 'rejected'}`); load();
  };

  if (loading) return <p>Loading queues...</p>;

  return (
    <div>
      <h2 style={styles.heading}>Pending Queues</h2>
      {msg && <div style={styles.toast}>{msg}</div>}

      <Section title={`🎫 Token Requests (${queues.tokens?.length ?? 0})`}>
        {queues.tokens?.length === 0 ? <Empty /> : queues.tokens.map(t => (
          <Row key={t.id}>
            <span><strong>{t.patientName}</strong> — {t.type}</span>
            <span style={{ color: '#888', fontSize: 13 }}>{t.scheduledTime || 'No time set'}</span>
            <Actions>
              <Btn color="#2e7d32" onClick={() => processToken(t.id, true)}>✅ Approve</Btn>
              <Btn color="#c62828" onClick={() => processToken(t.id, false)}>❌ Reject</Btn>
            </Actions>
          </Row>
        ))}
      </Section>

      <Section title={`🔁 Referral Requests (${queues.referrals?.length ?? 0})`}>
        {queues.referrals?.length === 0 ? <Empty /> : queues.referrals.map(r => (
          <Row key={r.id}>
            <div>
              <strong>{r.patientName}</strong> — from Dr. {r.fromDoctor}
              <br /><small style={{ color: '#888' }}>{r.requestedSpecialty} · {r.urgency} · {r.reason}</small>
            </div>
            <Actions>
              <Btn color="#2e7d32" onClick={() => processReferral(r.id, true)}>✅ Approve</Btn>
              <Btn color="#c62828" onClick={() => processReferral(r.id, false)}>❌ Reject</Btn>
            </Actions>
          </Row>
        ))}
      </Section>
    </div>
  );
}

const Section = ({ title, children }) => (
  <div style={{ background: '#fff', borderRadius: 12, padding: 24, marginBottom: 24, boxShadow: '0 2px 12px rgba(0,0,0,0.07)' }}>
    <h3 style={{ margin: '0 0 16px', color: '#1a237e' }}>{title}</h3>
    {children}
  </div>
);
const Row = ({ children }) => (
  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 0', borderBottom: '1px solid #f0f0f0', gap: 12, flexWrap: 'wrap' }}>
    {children}
  </div>
);
const Actions = ({ children }) => <div style={{ display: 'flex', gap: 8 }}>{children}</div>;
const Btn = ({ color, onClick, children }) => (
  <button onClick={onClick} style={{ background: color, color: '#fff', border: 'none', borderRadius: 6, padding: '7px 14px', cursor: 'pointer', fontSize: 13 }}>{children}</button>
);
const Empty = () => <p style={{ color: '#aaa', textAlign: 'center', padding: 20 }}>No pending items</p>;

const styles = {
  heading: { margin: '0 0 24px', color: '#1a237e', fontSize: 24 },
  toast: { background: '#e8f5e9', color: '#2e7d32', padding: '10px 16px', borderRadius: 8, marginBottom: 16, fontSize: 14 },
};
