import { useEffect, useState } from 'react';
import api from '../../api/axios';

const LEVEL_COLOR = { CRITICAL: '#c62828', URGENT: '#e65100', NORMAL: '#2e7d32' };

export default function Emergencies() {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);

  const load = () => api.get('/api/md/emergencies').then(r => { setAlerts(r.data); setLoading(false); }).catch(() => setLoading(false));
  useEffect(load, []);

  const ack = async (id) => {
    await api.put(`/api/md/emergencies/${id}/acknowledge`);
    load();
  };

  if (loading) return <p>Loading emergencies...</p>;

  return (
    <div>
      <h2 style={{ margin: '0 0 24px', color: '#c62828', fontSize: 24 }}>🚨 Emergency Alerts</h2>
      {alerts.length === 0
        ? <div style={styles.empty}>✅ No active emergencies</div>
        : alerts.map(a => (
          <div key={a.id} style={{ ...styles.card, borderLeft: `5px solid ${LEVEL_COLOR[a.level] || '#888'}` }}>
            <div>
              <span style={{ ...styles.badge, background: LEVEL_COLOR[a.level] || '#888' }}>{a.level}</span>
              <strong style={{ marginLeft: 10 }}>{a.patientName || `Patient #${a.id}`}</strong>
              <p style={styles.time}>{new Date(a.alertTime).toLocaleString()}</p>
            </div>
            {!a.acknowledged
              ? <button style={styles.ackBtn} onClick={() => ack(a.id)}>✅ Acknowledge</button>
              : <span style={styles.acked}>Acknowledged</span>}
          </div>
        ))
      }
    </div>
  );
}

const styles = {
  card: { background: '#fff', borderRadius: 10, padding: '16px 20px', marginBottom: 14, boxShadow: '0 2px 10px rgba(0,0,0,0.07)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' },
  badge: { color: '#fff', padding: '3px 10px', borderRadius: 20, fontSize: 12, fontWeight: 700 },
  time: { margin: '4px 0 0', fontSize: 12, color: '#888' },
  ackBtn: { background: '#1565c0', color: '#fff', border: 'none', borderRadius: 6, padding: '8px 16px', cursor: 'pointer', fontSize: 13 },
  acked: { color: '#2e7d32', fontWeight: 600, fontSize: 13 },
  empty: { background: '#e8f5e9', color: '#2e7d32', padding: 24, borderRadius: 12, textAlign: 'center', fontSize: 16 },
};
