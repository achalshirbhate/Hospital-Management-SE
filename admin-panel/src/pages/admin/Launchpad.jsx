import { useEffect, useState } from 'react';
import api from '../../api/axios';

export default function Launchpad() {
  const [ideas, setIdeas] = useState([]);
  const [loading, setLoading] = useState(true);

  const load = () => api.get('/api/shared/launchpad').then(r => { setIdeas(r.data); setLoading(false); }).catch(() => setLoading(false));
  useEffect(load, []);

  const respond = async (id) => {
    const response = prompt('Enter your response:');
    if (!response) return;
    await api.put(`/api/md/launchpad/${id}/respond`, { response });
    load();
  };

  if (loading) return <p>Loading LaunchPad...</p>;

  return (
    <div>
      <h2 style={styles.heading}>💡 LaunchPad Submissions ({ideas.length})</h2>
      {ideas.length === 0
        ? <p style={{ color: '#aaa' }}>No submissions yet</p>
        : ideas.map(i => (
          <div key={i.id} style={styles.card}>
            <div style={styles.top}>
              <div>
                <h3 style={styles.title}>{i.ideaTitle}</h3>
                <span style={styles.domain}>{i.domain}</span>
              </div>
              <button style={styles.btn} onClick={() => respond(i.id)}>💬 Respond</button>
            </div>
            <p style={styles.desc}>{i.description}</p>
            <p style={styles.meta}>By: {i.submitterEmail} · {i.submittedAt ? new Date(i.submittedAt).toLocaleDateString() : ''}</p>
            {i.response && <p style={styles.response}>📩 Response: {i.response}</p>}
          </div>
        ))
      }
    </div>
  );
}

const styles = {
  heading: { margin: '0 0 24px', color: '#1a237e', fontSize: 24 },
  card: { background: '#fff', borderRadius: 12, padding: 24, marginBottom: 16, boxShadow: '0 2px 12px rgba(0,0,0,0.07)' },
  top: { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 },
  title: { margin: '0 0 6px', color: '#1a237e', fontSize: 17 },
  domain: { background: '#e3f2fd', color: '#1565c0', padding: '2px 10px', borderRadius: 20, fontSize: 12 },
  desc: { color: '#555', fontSize: 14, margin: '8px 0' },
  meta: { color: '#aaa', fontSize: 12 },
  response: { background: '#f1f8e9', color: '#33691e', padding: '8px 12px', borderRadius: 6, fontSize: 13, marginTop: 8 },
  btn: { background: '#1565c0', color: '#fff', border: 'none', borderRadius: 6, padding: '7px 14px', cursor: 'pointer', fontSize: 13, whiteSpace: 'nowrap' },
};
