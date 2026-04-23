# 🚀 TelePatient — Production Deployment Guide

## Architecture
```
Flutter App  ──┐
React Panel  ──┼──► Render (Spring Boot API) ──► Supabase (PostgreSQL)
Postman      ──┘         ↕ WebSocket (wss://)
```

---

## 1. Backend — Deploy on Render

### Step 1: Push to GitHub
```bash
git add .
git commit -m "production: JWT security + admin panel"
git push origin main
```

### Step 2: Create Render Web Service
1. Go to https://render.com → New → Web Service
2. Connect your GitHub repo
3. Set:
   - **Root Directory:** `auth-service`
   - **Build Command:** `mvn clean package -DskipTests`
   - **Start Command:** `java -jar target/auth-service-0.0.1-SNAPSHOT.jar`
   - **Runtime:** Java

### Step 3: Set Environment Variables on Render
```
DB_URL          = jdbc:postgresql://aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require
DB_USERNAME     = postgres.YOUR_PROJECT_REF
DB_PASSWORD     = YOUR_SUPABASE_PASSWORD
JWT_SECRET      = (generate: openssl rand -base64 64)
JWT_EXPIRATION_MS = 86400000
MAIL_USERNAME   = your@gmail.com
MAIL_PASSWORD   = your_gmail_app_password
CORS_ALLOWED_ORIGINS = https://your-admin-panel.vercel.app,https://your-flutter-app.com
PORT            = 8081
```

### Step 4: Your backend URL will be:
```
https://telepatient-backend.onrender.com
```

---

## 2. Admin Panel — Deploy on Vercel

### Step 1: Create .env file
```bash
cd admin-panel
cp .env.example .env
# Edit .env: set VITE_API_URL=https://telepatient-backend.onrender.com
```

### Step 2: Install dependencies
```bash
npm install
```

### Step 3: Deploy to Vercel
```bash
npm install -g vercel
vercel --prod
```
Or connect GitHub repo at https://vercel.com → New Project → Import

### Step 4: Set Vercel Environment Variable
```
VITE_API_URL = https://telepatient-backend.onrender.com
```

---

## 3. Flutter App — Update API URL

In `tele_patient_app/lib/core/constants/api_constants.dart`:
```dart
static const baseUrl = 'https://telepatient-backend.onrender.com/api';
```

In `tele_patient_app/lib/core/services/websocket_service.dart`:
```dart
final wsUrl = 'wss://telepatient-backend.onrender.com/ws/video?token=$token';
```

---

## 4. Security Checklist

- [x] JWT authentication on all protected endpoints
- [x] BCrypt password hashing
- [x] Role-based access control (PATIENT / DOCTOR / MAIN_DOCTOR)
- [x] CORS restricted to known origins
- [x] CSRF disabled (stateless JWT API)
- [x] Input validation (@Valid annotations)
- [x] Global exception handler
- [x] Environment variables (no hardcoded secrets)
- [x] HTTPS enforced by Render/Vercel
- [x] WebSocket JWT handshake validation

---

## 5. API Authentication

All protected endpoints require:
```
Authorization: Bearer <JWT_TOKEN>
```

### Login to get token:
```bash
curl -X POST https://telepatient-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@hospital.com","password":"yourpassword"}'
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "userId": 1,
  "role": "MAIN_DOCTOR",
  "fullName": "Dr. Admin"
}
```

### Use token:
```bash
curl https://telepatient-backend.onrender.com/api/md/dashboard \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

---

## 6. Create First Admin Account

Since registration creates PATIENT role, use this SQL on Supabase to create your first MD:

```sql
-- Run in Supabase SQL Editor
UPDATE users SET role = 'MAIN_DOCTOR' WHERE email = 'your@email.com';
```

Or register normally, then use the promote endpoint (after manually setting one MD):
```bash
POST /api/md/promote?email=doctor@hospital.com&name=Dr.Smith&role=DOCTOR
```

---

## 7. Local Development

### Backend:
```bash
cd auth-service
# Create .env file from .env.example
export $(cat .env | xargs)
mvn spring-boot:run
```

### Admin Panel:
```bash
cd admin-panel
cp .env.example .env
# Set VITE_API_URL=http://localhost:8081
npm install
npm run dev
```

---

## 8. Railway Alternative

If using Railway instead of Render:
1. Go to https://railway.app → New Project → Deploy from GitHub
2. Set root directory to `auth-service`
3. Add same environment variables
4. Railway auto-detects Maven and builds

---

## 9. Postman Collection

Import this to test all APIs:

Base URL: `{{API_URL}}` = `https://telepatient-backend.onrender.com`

| Method | Endpoint | Auth | Body |
|--------|----------|------|------|
| POST | /api/auth/register | None | `{fullName, email, password}` |
| POST | /api/auth/login | None | `{email, password}` |
| POST | /api/auth/forgot-password?email= | None | — |
| GET | /api/md/dashboard | Bearer | — |
| GET | /api/md/queues | Bearer | — |
| PUT | /api/md/tokens/{id}?approve=true | Bearer | — |
| PUT | /api/md/referrals/{id}/assign?approve=true&assignedDoctorId= | Bearer | — |
| GET | /api/md/emergencies | Bearer | — |
| PUT | /api/md/emergencies/{id}/acknowledge | Bearer | — |
| POST | /api/md/promote?email=&name=&role= | Bearer | — |
| POST | /api/md/finance | Bearer | `{type, amount, description}` |
| GET | /api/doctor/{id}/patients | Bearer | — |
| POST | /api/doctor/{id}/consultations?patientId=&notes= | Bearer | — |
| POST | /api/doctor/{id}/referrals | Bearer | `{patientId, requestedSpecialty, urgency, reason}` |
| GET | /api/patient/{id}/history | Bearer | — |
| GET | /api/patient/{id}/tokens | Bearer | — |
| POST | /api/patient/tokens | Bearer | `{patientId, mdId, type}` |
| POST | /api/patient/{id}/emergency?level=CRITICAL | Bearer | — |
| GET | /api/chat/{tokenId} | Bearer | — |
| POST | /api/chat/{tokenId}?senderId= | Bearer | `"message text"` |
| GET | /api/notifications/{userId} | Bearer | — |
| GET | /api/shared/social | Bearer | — |
| POST | /api/shared/launchpad | Bearer | `{submitterId, ideaTitle, description, domain}` |

---

*Generated: April 2026 | TelePatient v2.0 — Production Ready*
