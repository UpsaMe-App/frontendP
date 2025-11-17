import 'package:flutter/material.dart';
import '../models/post_models.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 22, backgroundImage: post.user?.profilePhotoUrl != null ? NetworkImage(post.user!.profilePhotoUrl!) : null, child: post.user?.profilePhotoUrl == null ? Text((post.user?.firstName ?? 'U').substring(0, 1)) : null),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)), if (post.subject != null) Text(post.subject!.name, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
              const SizedBox(width: 8),
              Text(post.createdAtUtc != null ? post.createdAtUtc!.split('T').first : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            const SizedBox(height: 10),
            if (post.title != null) Text(post.title!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(post.content, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.comment, size: 16, color: Colors.grey[600]), const SizedBox(width: 6), Text('${post.replies?.length ?? 0}'),]),
          ]),
        ),
      ),
    );
  }
}
