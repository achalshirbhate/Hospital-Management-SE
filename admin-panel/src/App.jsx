import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Layout from './components/Layout';
import Login from './pages/Login';

// Admin pages
import Dashboard    from './pages/admin/Dashboard';
import Queues       from './pages/admin/Queues';
import Emergencies  from './pages/admin/Emergencies';
import Patients     from './pages/admin/Patients';
import Doctors      from './pages/admin/Doctors';
import RoleManagement from './pages/admin/RoleManagement';
import Finance      from './pages/admin/Finance';
import Launchpad    from './pages/admin/Launchpad';

// Doctor pages
import DoctorPatients from './pages/doctor/Patients';

// Patient pages
import PatientHistory      from './pages/patient/History';
import PatientAppointments from './pages/patient/Appointments';

function ProtectedRoute({ children, roles }) {
  const { user, isLoggedIn } = useAuth();
  if (!isLoggedIn) return <Navigate to="/login" replace />;
  if (roles && !roles.includes(user?.role)) return <Navigate to="/login" replace />;
  return <Layout>{children}</Layout>;
}

function AppRoutes() {
  const { user, isLoggedIn } = useAuth();
  return (
    <Routes>
      <Route path="/login" element={isLoggedIn
        ? <Navigate to={user?.role === 'MAIN_DOCTOR' ? '/admin/dashboard' : user?.role === 'DOCTOR' ? '/doctor/patients' : '/patient/history'} />
        : <Login />}
      />

      {/* Admin */}
      <Route path="/admin/dashboard"   element={<ProtectedRoute roles={['MAIN_DOCTOR']}><Dashboard /></ProtectedRoute>} />
      <Route path="/admin/queues"      element={<ProtectedRoute roles={['MAIN_DOCTOR']}><Queues /></ProtectedRoute>} />
      <Route path="/admin/emergencies" element={<ProtectedRoute roles={['MAIN_DOCTOR']}><Emergencies /></ProtectedRoute>} />
      <Route path="/admin/patients"    element={<ProtectedRoute roles={['MAIN_DOCTOR']}><Patients /></ProtectedRoute>} />
      <Route path="/admin/doctors"     element={<ProtectedRoute roles={['MAIN_DOCTOR']}><Doctors /></ProtectedRoute>} />
      <Route path="/admin/roles"       element={<ProtectedRoute roles={['MAIN_DOCTOR']}><RoleManagement /></ProtectedRoute>} />
      <Route path="/admin/finance"     element={<ProtectedRoute roles={['MAIN_DOCTOR']}><Finance /></ProtectedRoute>} />
      <Route path="/admin/launchpad"   element={<ProtectedRoute roles={['MAIN_DOCTOR']}><Launchpad /></ProtectedRoute>} />

      {/* Doctor */}
      <Route path="/doctor/patients"      element={<ProtectedRoute roles={['DOCTOR', 'MAIN_DOCTOR']}><DoctorPatients /></ProtectedRoute>} />

      {/* Patient */}
      <Route path="/patient/history"      element={<ProtectedRoute roles={['PATIENT']}><PatientHistory /></ProtectedRoute>} />
      <Route path="/patient/appointments" element={<ProtectedRoute roles={['PATIENT']}><PatientAppointments /></ProtectedRoute>} />

      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </AuthProvider>
  );
}
