import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: c, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c),
              overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
