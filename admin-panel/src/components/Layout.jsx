import { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const NAV = {
  MAIN_DOCTOR: [
    { path: '/admin/dashboard',  label: '📊 Dashboard' },
    { path: '/admin/queues',     label: '📋 Queues' },
    { path: '/admin/emergencies',label: '🚨 Emergencies' },
    { path: '/admin/patients',   label: '👥 Patients' },
    { path: '/admin/doctors',    label: '👨‍⚕️ Doctors' },
    { path: '/admin/roles',      label: '🔑 Role Mgmt' },
    { path: '/admin/launchpad',  label: '💡 LaunchPad' },
    { path: '/admin/finance',    label: '💰 Finance' },
  ],
  DOCTOR: [
    { path: '/doctor/patients',     label: '👥 My Patients' },
    { path: '/doctor/consultations',label: '📝 Consultations' },
    { path: '/doctor/referrals',    label: '🔁 Referrals' },
  ],
  PATIENT: [
    { path: '/patient/history',     label: '📋 My History' },
    { path: '/patient/appointments',label: '📅 Appointments' },
    { path: '/patient/reports',     label: '📁 Reports' },
  ],
};

export default function Layout({ children }) {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [collapsed, setCollapsed] = useState(false);
  const links = NAV[user?.role] || [];

  const handleLogout = () => { logout(); navigate('/login'); };

  return (
    <div style={styles.root}>
      {/* Sidebar */}
      <aside style={{ ...styles.sidebar, width: collapsed ? 60 : 220 }}>
        <div style={styles.sideTop}>
          <span style={styles.sideTitle}>{collapsed ? '🏥' : '🏥 TelePatient'}</span>
          <button style={styles.collapseBtn} onClick={() => setCollapsed(!collapsed)}>
            {collapsed ? '→' : '←'}
          </button>
        </div>
        <nav>
          {links.map(l => (
            <Link key={l.path} to={l.path} style={{
              ...styles.navLink,
              background: location.pathname === l.path ? '#1565c0' : 'transparent',
            }}>
              {collapsed ? l.label.split(' ')[0] : l.label}
            </Link>
          ))}
        </nav>
        <div style={styles.sideBottom}>
          {!collapsed && <p style={styles.userInfo}>{user?.fullName}<br /><small>{user?.role}</small></p>}
          <button style={styles.logoutBtn} onClick={handleLogout}>
            {collapsed ? '🚪' : '🚪 Logout'}
          </button>
        </div>
      </aside>

      {/* Main */}
      <main style={styles.main}>{children}</main>
    </div>
  );
}

const styles = {
  root: { display: 'flex', minHeight: '100vh', fontFamily: 'Inter, sans-serif' },
  sidebar: { background: '#0d47a1', color: '#fff', display: 'flex', flexDirection: 'column', transition: 'width 0.2s', overflow: 'hidden', flexShrink: 0 },
  sideTop: { padding: '20px 12px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.15)' },
  sideTitle: { fontWeight: 700, fontSize: 15, whiteSpace: 'nowrap', overflow: 'hidden' },
  collapseBtn: { background: 'none', border: 'none', color: '#fff', cursor: 'pointer', fontSize: 16 },
  navLink: { display: 'block', padding: '11px 16px', color: '#e3f2fd', textDecoration: 'none', fontSize: 14, borderRadius: 6, margin: '2px 8px', whiteSpace: 'nowrap', overflow: 'hidden' },
  sideBottom: { marginTop: 'auto', padding: 12, borderTop: '1px solid rgba(255,255,255,0.15)' },
  userInfo: { fontSize: 13, color: '#bbdefb', marginBottom: 10 },
  logoutBtn: { width: '100%', padding: '9px', background: '#c62828', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 13 },
  main: { flex: 1, background: '#f5f7fa', padding: 28, overflowY: 'auto' },
};
