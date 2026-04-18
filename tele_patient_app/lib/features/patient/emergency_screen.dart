import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_button.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _sending = false;

  Future<void> _send(String level) async {
    setState(() => _sending = true);
    final user = context.read<AuthProvider>().user!;
    try {
      final msg = await ApiService.triggerEmergency(user.userId, level);
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Alert Sent!'),
        content: Text(msg),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('OK'))],
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Alert'),
        backgroundColor: AppColors.danger, foregroundColor: Colors.white),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.emergency, size: 80, color: AppColors.danger),
          const SizedBox(height: 16),
          const Text('Select Alert Level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Hospital staff will be notified immediately.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 40),
          _LevelButton(label: '🔴 Critical — Need help NOW', color: AppColors.danger,
            onTap: _sending ? null : () => _send('CRITICAL')),
          const SizedBox(height: 14),
          _LevelButton(label: '🟡 Urgent — Need assistance soon', color: AppColors.warning,
            onTap: _sending ? null : () => _send('URGENT')),
          const SizedBox(height: 14),
          _LevelButton(label: '🟢 Normal — General assistance', color: AppColors.success,
            onTap: _sending ? null : () => _send('NORMAL')),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          _ContactTile(icon: Icons.local_hospital, label: 'Hospital Emergency', number: '108'),
          _ContactTile(icon: Icons.emergency, label: 'Ambulance', number: '102'),
          _ContactTile(icon: Icons.local_police, label: 'Police', number: '100'),
        ],
      )),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _LevelButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ));
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  const _ContactTile({required this.icon, required this.label, required this.number});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: Text(number, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16)),
    );
  }
}
