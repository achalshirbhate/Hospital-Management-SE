import { useState } from 'react';
import api from '../../api/axios';

export default function RoleManagement() {
  const [form, setForm] = useState({ email: '', fullName: '', role: 'DOCTOR' });
  const [msg, setMsg] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMsg(''); setError(''); setLoading(true);
    try {
      await api.post(`/api/md/promote?email=${encodeURIComponent(form.email)}&fullName=${encodeURIComponent(form.fullName)}&role=${form.role}`);
      setMsg(`✅ User promoted to ${form.role} successfully`);
      setForm({ email: '', fullName: '', role: 'DOCTOR' });
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to promote user');
    } finally { setLoading(false); }
  };

  return (
    <div>
      <h2 style={styles.heading}>🔑 Role Management</h2>
      <div style={styles.card}>
        <h3 style={styles.subheading}>Promote / Create User</h3>
        <p style={styles.hint}>If the email exists, their role will be updated. If not, a new account is created with password <code>temp@123</code>.</p>
        <form onSubmit={handleSubmit}>
          <label style={styles.label}>Email</label>
          <input style={styles.input} type="email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} required placeholder="user@hospital.com" />
          <label style={styles.label}>Full Name</label>
          <input style={styles.input} value={form.fullName} onChange={e => setForm({ ...form, fullName: e.target.value })} required placeholder="Dr. John Smith" />
          <label style={styles.label}>Role</label>
          <select style={styles.input} value={form.role} onChange={e => setForm({ ...form, role: e.target.value })}>
            <option value="DOCTOR">DOCTOR</option>
            <option value="MAIN_DOCTOR">MAIN_DOCTOR (Admin)</option>
            <option value="PATIENT">PATIENT</option>
          </select>
          {msg && <p style={styles.success}>{msg}</p>}
          {error && <p style={styles.error}>{error}</p>}
          <button style={styles.btn} type="submit" disabled={loading}>{loading ? 'Processing...' : 'Promote User'}</button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 24px', color: '#1a237e', fontSize: 24 },
  card: { background: '#fff', borderRadius: 12, padding: 32, maxWidth: 480, boxShadow: '0 2px 12px rgba(0,0,0,0.07)' },
  subheading: { margin: '0 0 8px', color: '#333' },
  hint: { fontSize: 13, color: '#888', marginBottom: 20 },
  label: { display: 'block', fontSize: 13, fontWeight: 600, color: '#555', marginBottom: 6 },
  input: { width: '100%', padding: '10px 12px', border: '1.5px solid #ddd', borderRadius: 8, fontSize: 14, marginBottom: 16, boxSizing: 'border-box' },
  btn: { width: '100%', padding: 12, background: '#1a237e', color: '#fff', border: 'none', borderRadius: 8, fontSize: 15, fontWeight: 600, cursor: 'pointer' },
  success: { color: '#2e7d32', fontSize: 14, marginBottom: 12 },
  error: { color: '#c62828', fontSize: 14, marginBottom: 12 },
};
