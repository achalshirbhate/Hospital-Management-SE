#!/bin/bash

# TelePatient Deployment Script
# This script helps you deploy to Render and rebuild the Flutter app

echo "=========================================="
echo "TelePatient Deployment Helper"
echo "=========================================="
echo ""

# Step 1: Git push
echo "Step 1: Pushing code to GitHub..."
read -p "Do you want to commit and push changes? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add .
    read -p "Enter commit message: " commit_msg
    git commit -m "$commit_msg"
    git push origin main
    echo "✓ Code pushed to GitHub"
else
    echo "⊘ Skipped git push"
fi

echo ""
echo "=========================================="
echo "Step 2: Deploy to Render"
echo "=========================================="
echo ""
echo "1. Go to: https://dashboard.render.com"
echo "2. Click 'New +' → 'Web Service'"
echo "3. Connect repository: achalshirbhate/Hospital-Management-SE"
echo "4. Render will auto-detect render.yaml"
echo "5. Add environment variables (see DEPLOYMENT_GUIDE.md)"
echo "6. Click 'Create Web Service'"
echo ""
read -p "Press Enter when deployment is complete..."

echo ""
echo "=========================================="
echo "Step 3: Update Flutter App"
echo "=========================================="
echo ""
read -p "Enter your Render backend URL (e.g., https://telepatient-api.onrender.com): " backend_url

# Update constants.dart
echo "Updating Flutter app configuration..."
cat > telepatient_app/lib/utils/constants.dart << EOF
// ─── App-wide constants ───────────────────────────────────────────────────────
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // Automatically picks the right URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081'; // Running in browser (Chrome)
    }
    return '$backend_url'; // Production backend on Render
  }

  static String get wsVideoUrl {
    if (kIsWeb) {
      return 'ws://localhost:8081/ws/video';
    }
    // Convert https:// to wss:// for WebSocket
    return '${backend_url/https:/wss:}/ws/video';
  }

  // Temp password that forces a reset
  static const String tempPassword = 'temp@123';

  // Chat polling interval in seconds
  static const int chatPollSeconds = 3;

  // SharedPreferences keys (non-sensitive session metadata)
  static const String prefUserId   = 'userId';
  static const String prefRole     = 'role';
  static const String prefFullName = 'fullName';
  static const String prefEmail    = 'email';
  static const String prefToken    = 'jwt_token';
}

// ─── Named routes ─────────────────────────────────────────────────────────────
class AppRoutes {
  static const String login   = '/login';
  static const String patient = '/patient';
  static const String doctor  = '/doctor';
  static const String md      = '/md';
}

// ─── Role constants ───────────────────────────────────────────────────────────
class AppRoles {
  static const String patient    = 'PATIENT';
  static const String doctor     = 'DOCTOR';
  static const String mainDoctor = 'MAIN_DOCTOR';
}

// ─── Token status ─────────────────────────────────────────────────────────────
class TokenStatus {
  static const String requested = 'REQUESTED';
  static const String approved  = 'APPROVED';
  static const String rejected  = 'REJECTED';
  static const String completed = 'COMPLETED';
}

// ─── Token types ──────────────────────────────────────────────────────────────
class TokenType {
  static const String chat  = 'CHAT';
  static const String video = 'VIDEO';
}

// ─── Emergency levels ─────────────────────────────────────────────────────────
class EmergencyLevel {
  static const String critical = 'CRITICAL';
  static const String urgent   = 'URGENT';
  static const String normal   = 'NORMAL';
}
EOF

echo "✓ Updated constants.dart with backend URL: $backend_url"

echo ""
echo "Building Flutter APK..."
cd telepatient_app
flutter clean
flutter build apk --release

echo ""
echo "=========================================="
echo "✓ Deployment Complete!"
echo "=========================================="
echo ""
echo "Your APK is ready at:"
echo "telepatient_app/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Transfer this APK to your phone and install it."
echo ""
echo "Test your backend at: $backend_url/actuator/health"
echo ""
