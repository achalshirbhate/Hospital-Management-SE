import 'package:flutter/material.dart';
import '../../services/md_service.dart';
import '../../models/launchpad_model.dart';
import '../../utils/helpers.dart';
import '../../utils/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';

class LaunchpadScreen extends StatefulWidget {
  final int mdId;
  const LaunchpadScreen({super.key, required this.mdId});

  @override
  State<LaunchpadScreen> createState() => _LaunchpadScreenState();
}

class _LaunchpadScreenState extends State<LaunchpadScreen> {
  final _service = MdService();
  List<LaunchpadModel> _ideas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _ideas = await _service.getLaunchpadSubmissions();
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(LaunchpadModel idea) async {
    final ctrl = TextEditingController(text: idea.response);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Respond to: ${idea.ideaTitle}'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
              labelText: 'Your response',
              alignLabelWithHint: true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send')),
        ],
      ),
    );
    if (ok != true || ctrl.text.isEmpty) return;
    try {
      await _service.respondToLaunchpad(idea.id, ctrl.text);
      if (mounted) { showSuccess(context, 'Response sent!'); _load(); }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Launchpad Ideas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _load,
          child: _ideas.isEmpty && !_loading
              ? const EmptyState(
                  message: 'No ideas submitted yet.',
                  icon: Icons.lightbulb_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ideas.length,
                  itemBuilder: (_, i) => _IdeaCard(
                    idea: _ideas[i],
                    onRespond: () => _respond(_ideas[i]),
                  ),
                ),
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final LaunchpadModel idea;
  final VoidCallback onRespond;
  const _IdeaCard({required this.idea, required this.onRespond});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(idea.ideaTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(idea.description,
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Row(children: [
            _Chip(idea.domain, Colors.blue),
            const SizedBox(width: 8),
            _Chip(idea.submitterEmail, Colors.grey),
          ]),
          if (idea.response != null && idea.response!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.reply, size: 16, color: AppTheme.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(idea.response!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.success)),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onRespond,
              icon: const Icon(Icons.reply, size: 16),
              label: Text(idea.response != null ? 'Update Response' : 'Respond'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
