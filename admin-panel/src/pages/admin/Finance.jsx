import { useState } from 'react';
import api from '../../api/axios';

export default function Finance() {
  const [form, setForm] = useState({ type: 'REVENUE', amount: '', description: '' });
  const [msg, setMsg] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setMsg(''); setError('');
    try {
      await api.post('/api/md/finance', form);
      setMsg('✅ Financial record added');
      setForm({ type: 'REVENUE', amount: '', description: '' });
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to add record');
    }
  };

  return (
    <div>
      <h2 style={styles.heading}>💰 Financial Records</h2>
      <div style={styles.card}>
        <h3 style={{ margin: '0 0 20px', color: '#333' }}>Add Transaction</h3>
        <form onSubmit={handleSubmit}>
          <label style={styles.label}>Type</label>
          <select style={styles.input} value={form.type} onChange={e => setForm({ ...form, type: e.target.value })}>
            <option value="REVENUE">Revenue</option>
            <option value="EXPENDITURE">Expenditure</option>
          </select>
          <label style={styles.label}>Amount (₹)</label>
          <input style={styles.input} type="number" min="0" step="0.01" value={form.amount}
            onChange={e => setForm({ ...form, amount: e.target.value })} required placeholder="0.00" />
          <label style={styles.label}>Description</label>
          <input style={styles.input} value={form.description}
            onChange={e => setForm({ ...form, description: e.target.value })} required placeholder="e.g. Consultation fees" />
          {msg && <p style={styles.success}>{msg}</p>}
          {error && <p style={styles.error}>{error}</p>}
          <button style={styles.btn} type="submit">Add Record</button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 24px', color: '#1a237e', fontSize: 24 },
  card: { background: '#fff', borderRadius: 12, padding: 32, maxWidth: 480, boxShadow: '0 2px 12px rgba(0,0,0,0.07)' },
  label: { display: 'block', fontSize: 13, fontWeight: 600, color: '#555', marginBottom: 6 },
  input: { width: '100%', padding: '10px 12px', border: '1.5px solid #ddd', borderRadius: 8, fontSize: 14, marginBottom: 16, boxSizing: 'border-box' },
  btn: { width: '100%', padding: 12, background: '#1a237e', color: '#fff', border: 'none', borderRadius: 8, fontSize: 15, fontWeight: 600, cursor: 'pointer' },
  success: { color: '#2e7d32', fontSize: 14, marginBottom: 12 },
  error: { color: '#c62828', fontSize: 14, marginBottom: 12 },
};
