import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';

class ActionBottomSheet extends StatelessWidget {
  final FileSystemEntity entity;
  final Function(String) onRename;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onMove;

  const ActionBottomSheet({
    super.key,
    required this.entity,
    required this.onRename,
    required this.onDelete,
    required this.onCopy,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final name = p.basename(entity.path);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    entity is Directory ? FontAwesomeIcons.folder : FontAwesomeIcons.file,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionItem(
            context,
            icon: FontAwesomeIcons.pen,
            label: 'Rename',
            onTap: () {
              Navigator.pop(context);
              _showRenameDialog(context);
            },
          ),
          _buildActionItem(
            context,
            icon: FontAwesomeIcons.copy,
            label: 'Copy',
            onTap: onCopy,
          ),
          _buildActionItem(
            context,
            icon: FontAwesomeIcons.scissors,
            label: 'Move',
            onTap: onMove,
          ),
          _buildActionItem(
            context,
            icon: FontAwesomeIcons.trashCan,
            label: 'Delete',
            color: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: color ?? AppTheme.primaryBlue, size: 18),
      title: Text(
        label,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: color ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: p.basenameWithoutExtension(entity.path));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onRename(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
