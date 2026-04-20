import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/shared_service.dart';
import '../../services/md_service.dart';
import '../../models/social_post_model.dart';
import '../../utils/helpers.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import 'launchpad_submit_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  final int? mdId; // if provided, MD can create posts
  const SocialFeedScreen({super.key, this.mdId});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final _sharedService = SharedService();
  final _mdService     = MdService();
  List<SocialPostModel> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _posts = await _sharedService.getSocialFeed();
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createPost() async {
    final titleCtrl   = TextEditingController();
    final contentCtrl = TextEditingController();
    final mediaCtrl   = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Announcement'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: 'Content *', alignLabelWithHint: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mediaCtrl,
              decoration: const InputDecoration(
                  labelText: 'Media URL (optional)'),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Post')),
        ],
      ),
    );
    if (ok != true || titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
    try {
      await _mdService.createPost(
        mdId: widget.mdId!,
        title: titleCtrl.text,
        content: contentCtrl.text,
        mediaUrl: mediaCtrl.text.isNotEmpty ? mediaCtrl.text : null,
      );
      if (mounted) { showSuccess(context, 'Post published!'); _load(); }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  Future<void> _deletePost(SocialPostModel post, int requesterId) async {
    try {
      await _sharedService.deleteSocialPost(post.id, requesterId);
      if (mounted) { showSuccess(context, 'Post deleted'); _load(); }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isMd = auth.role == AppRoles.mainDoctor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: isMd
          ? FloatingActionButton.extended(
              onPressed: _createPost,
              icon: const Icon(Icons.add),
              label: const Text('Post'),
            )
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) =>
                          LaunchpadSubmitScreen(userId: auth.userId))),
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Submit Idea'),
              backgroundColor: Colors.amber,
            ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _load,
          child: _posts.isEmpty && !_loading
              ? const EmptyState(
                  message: 'No posts yet.',
                  icon: Icons.feed_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts.length,
                  itemBuilder: (_, i) {
                    final post = _posts[i];
                    final canDelete = isMd ||
                        post.authorId == auth.userId;
                    return _PostCard(
                      post: post,
                      canDelete: canDelete,
                      onDelete: () =>
                          _deletePost(post, auth.userId),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final SocialPostModel post;
  final bool canDelete;
  final VoidCallback onDelete;
  const _PostCard(
      {required this.post,
      required this.canDelete,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.15),
            child: Text(
              post.authorName.isNotEmpty
                  ? post.authorName[0].toUpperCase()
                  : 'M',
              style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(post.authorName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(formatDate(post.postedAt),
              style: const TextStyle(fontSize: 11)),
          trailing: canDelete
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                )
              : null,
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(post.content,
                style: TextStyle(color: Colors.grey.shade700)),
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.link, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(post.mediaUrl!,
                        style: const TextStyle(
                            color: Colors.blue, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
