import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../api/axios';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(''); setLoading(true);
    try {
      const { data } = await api.post('/api/auth/login', { email, password });
      login(data);
      if (data.role === 'MAIN_DOCTOR') navigate('/admin/dashboard');
      else if (data.role === 'DOCTOR') navigate('/doctor/patients');
      else navigate('/patient/history');
    } catch (err) {
      setError(err.response?.data?.error || 'Login failed');
    } finally { setLoading(false); }
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <div style={styles.logo}>🏥</div>
        <h1 style={styles.title}>TelePatient</h1>
        <p style={styles.subtitle}>Healthcare Management System</p>
        <form onSubmit={handleSubmit}>
          <input style={styles.input} type="email" placeholder="Email" value={email}
            onChange={e => setEmail(e.target.value)} required />
          <input style={styles.input} type="password" placeholder="Password" value={password}
            onChange={e => setPassword(e.target.value)} required />
          {error && <p style={styles.error}>{error}</p>}
          <button style={styles.btn} type="submit" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
        <p style={styles.hint}>Roles: Admin (MD) · Doctor · Patient</p>
      </div>
    </div>
  );
}

const styles = {
  page: { minHeight: '100vh', background: 'linear-gradient(135deg,#1a237e,#0d47a1)', display: 'flex', alignItems: 'center', justifyContent: 'center' },
  card: { background: '#fff', borderRadius: 16, padding: '40px 36px', width: 380, boxShadow: '0 20px 60px rgba(0,0,0,0.3)' },
  logo: { fontSize: 48, textAlign: 'center' },
  title: { textAlign: 'center', margin: '8px 0 4px', color: '#1a237e', fontSize: 28, fontWeight: 700 },
  subtitle: { textAlign: 'center', color: '#666', marginBottom: 28, fontSize: 14 },
  input: { width: '100%', padding: '12px 14px', marginBottom: 14, border: '1.5px solid #ddd', borderRadius: 8, fontSize: 15, boxSizing: 'border-box', outline: 'none' },
  btn: { width: '100%', padding: '13px', background: '#1a237e', color: '#fff', border: 'none', borderRadius: 8, fontSize: 16, fontWeight: 600, cursor: 'pointer' },
  error: { color: '#d32f2f', fontSize: 13, marginBottom: 10, textAlign: 'center' },
  hint: { textAlign: 'center', color: '#999', fontSize: 12, marginTop: 20 },
};
