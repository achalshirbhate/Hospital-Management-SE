import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'tabs/md_home_tab.dart';
import 'tabs/md_patients_tab.dart';
import 'tabs/md_queues_tab.dart';
import 'tabs/md_finance_tab.dart';
import 'tabs/md_more_tab.dart';

class MdDashboard extends StatefulWidget {
  const MdDashboard({super.key});

  @override
  State<MdDashboard> createState() => _MdDashboardState();
}

class _MdDashboardState extends State<MdDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final tabs = [
      MdHomeTab(mdId: auth.userId),
      MdPatientsTab(mdId: auth.userId),
      MdQueuesTab(mdId: auth.userId),
      MdFinanceTab(mdId: auth.userId),
      MdMoreTab(mdId: auth.userId),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'People'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions_outlined),
              activeIcon: Icon(Icons.pending_actions),
              label: 'Queues'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Finance'),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.more_horiz),
              label: 'More'),
        ],
      ),
    );
  }
}
