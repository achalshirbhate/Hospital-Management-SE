# 🏥 TelePatient System - Complete Architecture Guide

## 🧠 1. OVERALL ARCHITECTURE (How Everything is Connected)

Your system works like this:

`
Frontend (Web/Flutter App)
         ↓
REST APIs (Spring Boot Backend - Port 8081)
         ↓
Database (MySQL - Patients, Doctors, Reports, Sessions)
         ↓
Real-time Layer (WebSocket / Notifications)
`

👉 **Every feature you listed is just a module using these layers**

---

## 🔗 2. CORE FLOW (STARTING POINT)

### 🔐 Authentication (Entry Point)

`
User logs in (Doctor / Patient / MD)
         ↓
Backend verifies credentials
         ↓
Returns JWT token
         ↓
Token used for all future requests
`

👉 **This connects EVERYTHING because:**
`
Login → Role → Dashboard → Features Access
`

**Files Involved:**
- Frontend: login_screen.dart
- Backend: AuthController.java
- Service: AuthService.java
- Security: SecurityConfig.java

---

## 👨‍⚕️ 3. ROLE-BASED SYSTEM (MAIN CONNECTION LOGIC)

| Role | Access |
|------|--------|
| **MD** | Full control |
| **Doctor** | Patient management |
| **Patient** | Personal health data |

👉 **Backend decides:**
`
JWT Token → Role → Allowed APIs → UI Screen
`

**How it works:**
1. User logs in
2. Backend checks User.role in database
3. Returns JWT with role embedded
4. Frontend reads role from JWT
5. Shows appropriate dashboard

**Files:**
- User.java (Entity with role field)
- Role.java (Enum: PATIENT, DOCTOR, MAIN_DOCTOR)
- JwtUtil.java (Token generation/validation)

---

## 🏥 4. DASHBOARDS INTERCONNECTION

### 🧑‍💼 MD Dashboard (Central Control)

**Connected Features:**

`
Analytics ← (Patients + Appointments + Tokens)
Emergency Alerts ← (Triggered by Patients)
Doctor Monitoring ← (Doctor Activity logs)
Patient Assignment → (Assign to Doctors)
Referrals Queue ← (Doctors send requests)
Tokens Queue ← (Patients request appointments)
`

👉 **Flow:**
`
Patient → Request Token → MD approves → Doctor assigned
Doctor → Referral → MD reviews → Approves
`

**Files:**
- Frontend: md_home.dart
- Backend: MDController.java
- Service: MDService.java
- Entities: CommunicationToken.java, ReferralRequest.java

**API Endpoints:**
- GET /api/md/dashboard - Get analytics
- GET /api/md/queues - Get pending queues
- POST /api/md/token/approve - Approve token
- POST /api/md/referral/process - Process referral

---

### 👨‍⚕️ Doctor Dashboard

**Connected Features:**

`
Patient List ← (Assigned by MD)
Patient History ← (Stored in DB)
Add Notes → (Saved to patient record)
Referrals → (Sent to MD)
Video Call ↔ Patient
Chat ↔ Patient
`

👉 **Flow:**
`
MD assigns patient → Doctor treats → Adds notes → Updates DB
`

**Files:**
- Frontend: doctor_home.dart
- Backend: DoctorController.java
- Service: DoctorService.java
- Entities: Consultation.java, MedicalReport.java

**API Endpoints:**
- GET /api/doctor/dashboard - Get doctor data
- GET /api/doctor/patients - Get patient list
- POST /api/doctor/consultation - Add consultation notes
- POST /api/doctor/refer - Create referral

---

### 👤 Patient Dashboard

**Connected Features:**

`
View History ← (Doctor entries)
Reports ← (Uploaded files)
Request Tokens → (MD queue)
Emergency Alert → (MD notified instantly)
Video Call ↔ Doctor
Chat ↔ Doctor
`

👉 **Flow:**
`
Patient → Requests appointment → MD approves → Doctor assigned
Patient → Gets treatment → Data stored → Visible later
`

**Files:**
- Frontend: patient_home.dart
- Backend: PatientController.java
- Service: PatientService.java
- Entities: PatientProfile.java, Consultation.java

**API Endpoints:**
- GET /api/patient/dashboard - Get patient data
- GET /api/patient/history - Get medical history
- POST /api/patient/token/request - Request appointment
- POST /api/patient/emergency - Trigger emergency

---

## 📞 5. COMMUNICATION SYSTEM

### 🎥 Video Call (WebRTC)

**Flow:**
`
Patient ↔ Doctor
         ↓
WebRTC connection (peer-to-peer)
         ↓
Backend used for signaling
`

**How it works:**
1. User clicks "Video Call"
2. Frontend creates WebRTC offer
3. Sends offer via WebSocket
4. Other user receives offer
5. Creates answer
6. Peer-to-peer connection established

**Files:**
- Frontend: ideo_call_screen.dart
- Backend: VideoSignalingHandler.java
- Config: WebSocketConfig.java

**WebSocket Messages:**
- ideo-offer - Initiate call
- ideo-answer - Accept call
- ice-candidate - Connection info

---

### 💬 Chat System

**Flow:**
`
User sends message
         ↓
Backend stores message
         ↓
WebSocket sends live update
         ↓
Other user receives instantly
`

**How it works:**
1. User types message
2. Clicks send
3. POST to /api/chat/send
4. Backend saves to ChatMessage table
5. WebSocket broadcasts to both users
6. Message appears in chat

**Files:**
- Frontend: chat_screen.dart
- Backend: ChatController.java
- Service: ChatService.java
- Entity: ChatMessage.java
- WebSocket: VideoSignalingHandler.java

**API Endpoints:**
- GET /api/chat/history/{tokenId} - Get chat history
- POST /api/chat/send - Send message

**WebSocket Messages:**
- chat-message - New message
- chat-terminated - Session ended

---

### 🔴 Emergency Alerts

**Flow:**
`
Patient clicks alert 🚨
         ↓
Backend saves event
         ↓
WebSocket triggers notification
         ↓
MD Dashboard updates instantly
`

**How it works:**
1. Patient clicks emergency button
2. POST to /api/patient/emergency
3. Backend creates EmergencyAlert record
4. WebSocket sends to all MDs
5. MD sees alert in Emergency tab
6. MD acknowledges alert

**Files:**
- Frontend: emergency_screen.dart (Patient)
- Frontend: md_home.dart (MD Emergency tab)
- Backend: PatientController.java
- Entity: EmergencyAlert.java

**API Endpoints:**
- POST /api/patient/emergency - Create alert
- GET /api/md/emergencies - Get all alerts
- POST /api/md/emergency/ack - Acknowledge alert

---

## 📊 6. DATA FLOW (VERY IMPORTANT)

All features rely on shared data:

### 🧾 Patient Data
`
Created by: Doctor
Viewed by: Patient & MD
Stored in: PatientProfile, Consultation tables
`

### 📁 Reports
`
Uploaded by: Doctor
Viewed by: Patient
Stored in: MedicalReport table + File system
`

### 📝 Notes
`
Added by: Doctor
Stored in: Consultation table
Used in: History & analytics
`

**Database Tables:**
- users - All users (Patient, Doctor, MD)
- patient_profiles - Patient details
- consultations - Medical consultations
- medical_reports - Uploaded reports
- chat_messages - Chat history
- communication_tokens - Appointment tokens
- eferral_requests - Referral requests
- emergency_alerts - Emergency alerts
- 
otifications - User notifications
- social_posts - Social feed posts
- launchpad_submissions - LaunchPad ideas

---

## 🔄 7. REAL-TIME SYSTEM (WebSocket)

**Used for:**
- Notifications 🔔
- Chat 💬
- Emergency 🚨
- Live updates

**Flow:**
`
Event happens → Backend → WebSocket → All clients updated
`

**How it works:**
1. Client connects to ws://localhost:8081/ws
2. Backend maintains connection
3. When event occurs, backend sends message
4. All connected clients receive update
5. Frontend updates UI

**Files:**
- Backend: VideoSignalingHandler.java
- Config: WebSocketConfig.java
- Frontend: websocket_service.dart

**Message Types:**
- chat-message - New chat message
- 
otification - New notification
- emergency-alert - New emergency
- ideo-offer - Video call offer
- ideo-answer - Video call answer
- ice-candidate - WebRTC connection

---

## �� 8. NOTIFICATION SYSTEM

**Connected to:**
- Emergency Alerts
- New Messages
- Appointment Updates
- Referrals

**Flow:**
`
Event occurs
         ↓
Backend creates Notification
         ↓
WebSocket sends to user
         ↓
Frontend shows notification
`

**Files:**
- Frontend: 
otification_service.dart
- Backend: NotificationController.java
- Entity: Notification.java

**API Endpoints:**
- GET /api/notifications - Get all notifications
- POST /api/notifications/read - Mark as read

---

## 📅 9. APPOINTMENT / TOKEN SYSTEM

**Flow:**
`
Patient → Request Token
         ↓
MD reviews queue
         ↓
Approve / Reject
         ↓
Doctor assigned
         ↓
Session scheduled
`

**How it works:**
1. Patient requests appointment
2. Creates CommunicationToken with status PENDING
3. MD sees in Queues tab
4. MD approves and assigns doctor
5. Status changes to APPROVED
6. Doctor and Patient can start session

**Files:**
- Entity: CommunicationToken.java
- Entity: TokenStatus.java (PENDING, APPROVED, REJECTED)
- Backend: MDController.java

**API Endpoints:**
- POST /api/patient/token/request - Request token
- GET /api/md/queues - Get pending tokens
- POST /api/md/token/approve - Approve token

---

## 📂 10. REPORT & FILE SYSTEM

**Flow:**
`
Doctor uploads report
         ↓
Stored in server / DB
         ↓
Patient downloads or views PDF
`

**How it works:**
1. Doctor selects file
2. POST to /api/reports/upload (multipart/form-data)
3. Backend saves file to disk
4. Creates MedicalReport record with file path
5. Patient can view/download

**Files:**
- Frontend: upload_report_screen.dart
- Frontend: patient_reports_screen.dart
- Backend: ReportController.java
- Entity: MedicalReport.java

**API Endpoints:**
- POST /api/reports/upload - Upload report
- GET /api/reports/patient/{id} - Get patient reports
- GET /api/reports/download/{id} - Download report

---

## 🌐 11. SOCIAL + FEEDBACK (Extra Layer)

### Social Feed
`
All users interact
         ↓
Posts stored in DB
         ↓
Displayed in feed
`

**Files:**
- Frontend: social_feed_screen.dart
- Entity: SocialPost.java

### LaunchPad
`
Ideas stored in DB
         ↓
Managed by MD
`

**Files:**
- Frontend: launchpad_screen.dart (Submit)
- Frontend: launchpad_submissions_screen.dart (MD View)
- Entity: LaunchpadSubmission.java

---

## 🔁 12. FULL SYSTEM FLOW (Simplified)

`
Login
  ↓
Role-based Dashboard
  ↓
Patient ↔ Doctor ↔ MD
  ↓
Appointments / Tokens
  ↓
Consultation (Video + Chat)
  ↓
Notes + Reports saved
  ↓
Notifications + Real-time updates
`

---

## 📋 13. COMPLETE FEATURE INTERCONNECTION MAP

`
┌─────────────────────────────────────────────────────────┐
│                    USER AUTHENTICATION                   │
│                    (JWT Token + Role)                    │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼───┐   ┌───▼────┐   ┌──▼──────┐
   │   MD   │   │ Doctor │   │ Patient │
   └────┬───┘   └───┬────┘   └──┬──────┘
        │           │            │
        │           │            │
   ┌────▼───────────▼────────────▼──────┐
   │         DATABASE (MySQL)            │
   │  - Users                            │
   │  - Consultations                    │
   │  - Reports                          │
   │  - Tokens                           │
   │  - Emergencies                      │
   │  - Notifications                    │
   └────┬────────────────────────────────┘
        │
   ┌────▼────────────────────────────────┐
   │    WEBSOCKET (Real-time Layer)      │
   │  - Chat                             │
   │  - Video Signaling                  │
   │  - Notifications                    │
   │  - Emergency Alerts                 │
   └─────────────────────────────────────┘
`

---

## 🎯 14. KEY INTEGRATION POINTS

### Point 1: Authentication → All Features
`
Every API call requires JWT token
Token contains user ID and role
Backend validates token before processing
`

### Point 2: Database → All Features
`
All data stored in MySQL
All features read/write to database
Shared tables connect features
`

### Point 3: WebSocket → Real-time Features
`
Single WebSocket connection per user
All real-time updates use same connection
Backend broadcasts to relevant users
`

### Point 4: Role → Access Control
`
Role determines API access
Role determines UI visibility
Backend enforces role-based permissions
`

---

## �� 15. TECHNICAL STACK

### Frontend (Flutter)
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **HTTP**: http package
- **WebSocket**: web_socket_channel
- **WebRTC**: flutter_webrtc
- **Storage**: flutter_secure_storage (JWT)
- **Notifications**: flutter_local_notifications

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.x
- **Security**: Spring Security + JWT
- **Database**: Spring Data JPA + MySQL
- **WebSocket**: Spring WebSocket
- **File Upload**: MultipartFile

### Database (MySQL)
- **Tables**: 15+ tables
- **Relationships**: Foreign keys
- **Indexes**: On user_id, token_id, etc.

---

## 📊 16. DATA RELATIONSHIPS

`
User (1) ──────── (Many) Consultations
User (1) ──────── (Many) MedicalReports
User (1) ──────── (Many) Notifications
User (1) ──────── (Many) ChatMessages

CommunicationToken (1) ──── (Many) ChatMessages
CommunicationToken (1) ──── (1) Consultation

ReferralRequest (1) ──── (1) User (from_doctor)
ReferralRequest (1) ──── (1) User (patient)
ReferralRequest (1) ──── (1) User (assigned_doctor)

EmergencyAlert (1) ──── (1) User (patient)
`

---

## 🚀 17. REQUEST FLOW EXAMPLE

### Example: Patient Requests Appointment

**Step 1: Patient Action**
`dart
// patient_home.dart
ApiService.requestToken(patientId, type: 'VIDEO_CALL')
`

**Step 2: API Call**
`
POST http://localhost:8081/api/patient/token/request
Headers: Authorization: Bearer <JWT>
Body: { "patientId": 123, "type": "VIDEO_CALL" }
`

**Step 3: Backend Processing**
`java
// PatientController.java
@PostMapping("/token/request")
public ResponseEntity<?> requestToken(@RequestBody TokenRequest request) {
    // Create token
    CommunicationToken token = new CommunicationToken();
    token.setPatient(patient);
    token.setStatus(TokenStatus.PENDING);
    tokenRepository.save(token);
    
    // Send notification to MD
    notificationService.notifyMD("New token request");
    
    return ResponseEntity.ok("Token requested");
}
`

**Step 4: Database Update**
`sql
INSERT INTO communication_tokens 
(patient_id, status, type, created_at) 
VALUES (123, 'PENDING', 'VIDEO_CALL', NOW());
`

**Step 5: WebSocket Notification**
`java
// Send to all MDs
webSocketHandler.sendToRole("MAIN_DOCTOR", {
    type: "token-request",
    tokenId: token.getId()
});
`

**Step 6: MD Dashboard Update**
`dart
// md_home.dart - WebSocket listener
WebSocketService.instance.messages.listen((message) {
    if (message['type'] == 'token-request') {
        _loadQueues(); // Refresh queues
    }
});
`

---

## ✅ 18. SUMMARY

Your TelePatient system is a **fully integrated healthcare management platform** where:

1. **Authentication** connects everything through JWT tokens
2. **Role-based access** determines what each user can do
3. **Database** stores all shared data
4. **WebSocket** provides real-time updates
5. **REST APIs** handle all operations
6. **Frontend** displays role-specific dashboards

**Every feature is connected through:**
- Shared database tables
- Common authentication
- Real-time WebSocket layer
- Role-based permissions

**The system flows:**
`
User → Login → Role → Dashboard → Features → Database → WebSocket → Updates
`

---

*Last Updated: April 18, 2026*
*Status: ✅ COMPLETE ARCHITECTURE DOCUMENTED*
