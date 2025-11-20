import 'package:flutter/material.dart';
import '../models/post_models.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const PostCard({super.key, required this.post, this.onTap, this.onDelete, this.onEdit});

  String _getRoleLabel(int role) {
    switch (role) {
      case 1:
        return '🤝 Ofrezco ayuda';
      case 2:
        return '🆘 Necesito ayuda';
      case 3:
        return '💬 Comentario';
      default:
        return '';
    }
  }

  Color _getRoleColor(int role) {
    switch (role) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFEFEF),
                backgroundImage: post.user?.profilePhotoUrl != null ? NetworkImage(post.user!.profilePhotoUrl!) : null,
                child: post.user?.profilePhotoUrl == null
                    ? Text(((post.user?.firstName ?? '').isNotEmpty ? (post.user?.firstName ?? 'U')[0] : 'U'), style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    Text(post.createdAtUtc != null ? post.createdAtUtc!.split('T').first : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 8),
                  if (post.subject != null) Wrap(children: [Chip(label: Text(post.subject!.name), backgroundColor: const Color(0xFFF1F8F3))]),
                ]),
              ),
              const SizedBox(width: 6),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  onSelected: (v) {
                    if (v == 'edit') onEdit?.call();
                    if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) {
                    final items = <PopupMenuEntry<String>>[];
                    if (onEdit != null) items.add(const PopupMenuItem(value: 'edit', child: Text('Editar')));
                    if (onDelete != null) items.add(const PopupMenuItem(value: 'delete', child: Text('Borrar')));
                    return items;
                  },
                ),
            ]),
            const SizedBox(height: 12),
            if (post.title != null && post.title!.isNotEmpty) Text(post.title!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            if (post.title != null && post.title!.isNotEmpty) const SizedBox(height: 8),
            Text(post.content, style: const TextStyle(fontSize: 15), maxLines: 6, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text('${post.replies?.length ?? 0}'),
                  ],
                ),
                // Badge de rol
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(post.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRoleLabel(post.role),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getRoleColor(post.role),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
