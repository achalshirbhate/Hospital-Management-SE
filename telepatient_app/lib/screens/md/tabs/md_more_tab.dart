import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../shared/social_feed_screen.dart';
import '../../shared/notifications_screen.dart';
import '../launchpad_screen.dart';
import '../promote_user_screen.dart';

class MdMoreTab extends StatefulWidget {
  final int mdId;
  const MdMoreTab({super.key, required this.mdId});

  @override
  State<MdMoreTab> createState() => _MdMoreTabState();
}

class _MdMoreTabState extends State<MdMoreTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            icon: Icons.feed,
            color: AppTheme.primary,
            title: 'Social Feed',
            subtitle: 'Post announcements for staff',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => SocialFeedScreen(mdId: widget.mdId))),
          ),
          _MenuCard(
            icon: Icons.lightbulb_outline,
            color: Colors.amber,
            title: 'Launchpad',
            subtitle: 'Review innovation submissions',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => LaunchpadScreen(mdId: widget.mdId))),
          ),
          _MenuCard(
            icon: Icons.notifications_outlined,
            color: Colors.purple,
            title: 'Notifications',
            subtitle: 'View system alerts',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => NotificationsScreen(userId: widget.mdId))),
          ),
          _MenuCard(
            icon: Icons.admin_panel_settings,
            color: Colors.teal,
            title: 'Promote User',
            subtitle: 'Assign roles to users',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const PromoteUserScreen())),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
