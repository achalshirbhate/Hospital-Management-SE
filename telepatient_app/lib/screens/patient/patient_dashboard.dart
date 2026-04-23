import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'tabs/patient_home_tab.dart';
import 'tabs/patient_tokens_tab.dart';
import 'tabs/patient_reports_tab.dart';
import '../shared/notifications_screen.dart';
import '../shared/social_feed_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // userId is read from AuthProvider inside each tab — not passed as a param.
    // This means tabs always use the current authenticated user's ID, even if
    // the session is refreshed mid-session.
    final auth = context.watch<AuthProvider>();

    final tabs = [
      PatientHomeTab(patientId: auth.userId),
      const PatientTokensTab(),          // no userId param — reads from provider
      PatientReportsTab(patientId: auth.userId),
      NotificationsScreen(userId: auth.userId),
      const SocialFeedScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Sessions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.feed_outlined),
              activeIcon: Icon(Icons.feed),
              label: 'Feed'),
        ],
      ),
    );
  }
}
