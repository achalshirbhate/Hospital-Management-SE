import { useEffect, useState } from 'react';
import api from '../../api/axios';
import StatCard from '../../components/StatCard';

export default function Dashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/api/md/dashboard').then(r => { setData(r.data); setLoading(false); }).catch(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading dashboard...</p>;
  if (!data) return <p style={{ color: 'red' }}>Failed to load dashboard. Check backend connection.</p>;

  const stats = [
    { title: 'Total Patients',      value: data.patientCount,         icon: '👥', color: '#1565c0' },
    { title: 'Active Doctors',      value: data.activeDoctors,        icon: '👨‍⚕️', color: '#2e7d32' },
    { title: 'Appointments',        value: data.totalAppointments,    icon: '📅', color: '#6a1b9a' },
    { title: 'Pending Referrals',   value: data.pendingReferrals,     icon: '🔁', color: '#e65100' },
    { title: 'Pending Tokens',      value: data.pendingTokenRequests, icon: '🎫', color: '#00838f' },
    { title: 'Total Revenue',       value: `₹${data.totalRevenue?.toFixed(0) ?? 0}`, icon: '💰', color: '#1b5e20' },
    { title: 'Total Expenses',      value: `₹${data.totalExpenses?.toFixed(0) ?? 0}`, icon: '📉', color: '#b71c1c' },
    { title: 'Profit / Loss',       value: `₹${data.profitLoss?.toFixed(0) ?? 0}`,   icon: '📊', color: data.profitLoss >= 0 ? '#2e7d32' : '#c62828' },
  ];

  return (
    <div>
      <h2 style={styles.heading}>Hospital Analytics Dashboard</h2>
      <div style={styles.grid}>
        {stats.map(s => <StatCard key={s.title} {...s} />)}
      </div>

      {data.doctorActivity && Object.keys(data.doctorActivity).length > 0 && (
        <div style={styles.section}>
          <h3 style={styles.sectionTitle}>Doctor Activity (Consultations)</h3>
          <table style={styles.table}>
            <thead><tr><th style={styles.th}>Doctor</th><th style={styles.th}>Consultations</th></tr></thead>
            <tbody>
              {Object.entries(data.doctorActivity).map(([doc, count]) => (
                <tr key={doc}>
                  <td style={styles.td}>👨‍⚕️ {doc}</td>
                  <td style={styles.td}><strong>{count}</strong></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 24px', color: '#1a237e', fontSize: 24 },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: 16, marginBottom: 32 },
  section: { background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 12px rgba(0,0,0,0.07)' },
  sectionTitle: { margin: '0 0 16px', color: '#333', fontSize: 17 },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', padding: '10px 14px', background: '#f0f4ff', color: '#1a237e', fontSize: 13, fontWeight: 600 },
  td: { padding: '10px 14px', borderBottom: '1px solid #f0f0f0', fontSize: 14 },
};
