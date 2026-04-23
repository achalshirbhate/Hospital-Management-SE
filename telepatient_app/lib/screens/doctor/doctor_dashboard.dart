import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'tabs/doctor_patients_tab.dart';
import 'tabs/doctor_add_patient_tab.dart';
import '../shared/notifications_screen.dart';
import '../shared/social_feed_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final tabs = [
      DoctorPatientsTab(doctorId: auth.userId),
      DoctorAddPatientTab(doctorId: auth.userId),
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
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Patients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add_outlined),
              activeIcon: Icon(Icons.person_add),
              label: 'Add Patient'),
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
