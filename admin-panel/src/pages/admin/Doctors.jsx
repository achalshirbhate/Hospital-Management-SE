import { useEffect, useState } from 'react';
import api from '../../api/axios';

export default function Doctors() {
  const [doctors, setDoctors] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/api/md/doctors').then(r => { setDoctors(r.data); setLoading(false); }).catch(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading doctors...</p>;

  return (
    <div>
      <h2 style={styles.heading}>👨‍⚕️ Active Doctors ({doctors.length})</h2>
      <div style={styles.grid}>
        {doctors.map(d => (
          <div key={d.id} style={styles.card}>
            <div style={styles.avatar}>{d.fullName?.[0] ?? '?'}</div>
            <h3 style={styles.name}>{d.fullName}</h3>
            <p style={styles.spec}>{d.specialty || d.historySummary || 'General Practice'}</p>
            <p style={styles.id}>ID: {d.id}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 24px', color: '#1a237e', fontSize: 24 },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: 16 },
  card: { background: '#fff', borderRadius: 12, padding: 24, textAlign: 'center', boxShadow: '0 2px 12px rgba(0,0,0,0.07)' },
  avatar: { width: 56, height: 56, borderRadius: '50%', background: '#1565c0', color: '#fff', fontSize: 24, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 12px' },
  name: { margin: '0 0 6px', fontSize: 16, color: '#1a237e' },
  spec: { margin: '0 0 8px', fontSize: 13, color: '#666' },
  id: { margin: 0, fontSize: 12, color: '#aaa' },
};
