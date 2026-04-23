export default function StatCard({ title, value, icon, color = '#1a237e', sub }) {
  return (
    <div style={{ background: '#fff', borderRadius: 12, padding: '20px 24px', boxShadow: '0 2px 12px rgba(0,0,0,0.07)', borderLeft: `4px solid ${color}`, minWidth: 160 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <span style={{ fontSize: 32 }}>{icon}</span>
        <div>
          <p style={{ margin: 0, fontSize: 13, color: '#888' }}>{title}</p>
          <p style={{ margin: 0, fontSize: 28, fontWeight: 700, color }}>{value ?? '—'}</p>
          {sub && <p style={{ margin: 0, fontSize: 12, color: '#aaa' }}>{sub}</p>}
        </div>
      </div>
    </div>
  );
}
