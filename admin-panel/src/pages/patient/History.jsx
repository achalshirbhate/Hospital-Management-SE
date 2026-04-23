import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../api/axios';

export default function PatientHistory() {
  const { user } = useAuth();
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get(`/api/patient/${user.userId}/history`)
      .then(r => { setHistory(r.data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading history...</p>;

  return (
    <div>
      <h2 style={styles.heading}>📋 My Medical History</h2>
      {history.length === 0
        ? <p style={{ color: '#aaa' }}>No consultations yet</p>
        : history.map((h, i) => (
          <div key={i} style={styles.card}>
            <div style={styles.header}>
              <strong>👨‍⚕️ Dr. {h.doctorName}</strong>
              <span style={styles.date}>{h.date ? new Date(h.date).toLocaleDateString() : ''}</span>
            </div>
            {h.notes && <p style={styles.field}><strong>Notes:</strong> {h.notes}</p>}
            {h.prescription && <p style={styles.field}><strong>💊 Prescription:</strong> {h.prescription}</p>}
            {h.reportsUrl && <p style={styles.field}><strong>📎 Report:</strong> <a href={h.reportsUrl} target="_blank" rel="noreferrer">{h.reportsUrl}</a></p>}
          </div>
        ))
      }
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 24px', color: '#1a237e', fontSize: 24 },
  card: { background: '#fff', borderRadius: 12, padding: 20, marginBottom: 14, boxShadow: '0 2px 10px rgba(0,0,0,0.07)' },
  header: { display: 'flex', justifyContent: 'space-between', marginBottom: 10 },
  date: { color: '#888', fontSize: 13 },
  field: { margin: '6px 0', fontSize: 14, color: '#444' },
};
