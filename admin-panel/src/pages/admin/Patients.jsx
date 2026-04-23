import { useEffect, useState } from 'react';
import api from '../../api/axios';

export default function Patients() {
  const [patients, setPatients] = useState([]);
  const [doctors, setDoctors] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    Promise.all([api.get('/api/md/patients'), api.get('/api/md/doctors')])
      .then(([p, d]) => { setPatients(p.data); setDoctors(d.data); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const assign = async (patientId) => {
    const docId = prompt(`Assign to Doctor ID:\n${doctors.map(d => `${d.id}: ${d.fullName}`).join('\n')}`);
    if (!docId) return;
    await api.put(`/api/md/patients/${patientId}/assign?doctorId=${docId}`);
    setMsg('Patient assigned successfully');
  };

  const filtered = patients.filter(p => p.fullName?.toLowerCase().includes(search.toLowerCase()));

  if (loading) return <p>Loading patients...</p>;

  return (
    <div>
      <h2 style={styles.heading}>👥 All Patients ({patients.length})</h2>
      {msg && <div style={styles.toast}>{msg}</div>}
      <input style={styles.search} placeholder="Search patients..." value={search} onChange={e => setSearch(e.target.value)} />
      <div style={styles.tableWrap}>
        <table style={styles.table}>
          <thead>
            <tr>{['ID', 'Name', 'Age', 'Assigned Doctor', 'Actions'].map(h => <th key={h} style={styles.th}>{h}</th>)}</tr>
          </thead>
          <tbody>
            {filtered.map(p => (
              <tr key={p.id}>
                <td style={styles.td}>{p.id}</td>
                <td style={styles.td}><strong>{p.fullName}</strong></td>
                <td style={styles.td}>{p.age ?? '—'}</td>
                <td style={styles.td}>{p.historySummary}</td>
                <td style={styles.td}>
                  <button style={styles.btn} onClick={() => assign(p.id)}>Assign Doctor</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 20px', color: '#1a237e', fontSize: 24 },
  toast: { background: '#e8f5e9', color: '#2e7d32', padding: '10px 16px', borderRadius: 8, marginBottom: 16, fontSize: 14 },
  search: { width: '100%', padding: '10px 14px', border: '1.5px solid #ddd', borderRadius: 8, fontSize: 14, marginBottom: 16, boxSizing: 'border-box' },
  tableWrap: { background: '#fff', borderRadius: 12, overflow: 'hidden', boxShadow: '0 2px 12px rgba(0,0,0,0.07)' },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', padding: '12px 16px', background: '#f0f4ff', color: '#1a237e', fontSize: 13, fontWeight: 600 },
  td: { padding: '12px 16px', borderBottom: '1px solid #f5f5f5', fontSize: 14 },
  btn: { background: '#1565c0', color: '#fff', border: 'none', borderRadius: 6, padding: '6px 12px', cursor: 'pointer', fontSize: 12 },
};
