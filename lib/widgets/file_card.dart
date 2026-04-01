import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';
import 'video_thumbnail.dart';

class FileCard extends StatelessWidget {
  final FileSystemEntity entity;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FileCard({
    super.key,
    required this.entity,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDirectory = entity is Directory;
    final name = p.basename(entity.path);
    final stat = entity.statSync();
    final date = DateFormat.yMMMd().add_jm().format(stat.modified);
    final size = isDirectory ? '' : _formatSize(entity as File);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: _buildLeading(isDirectory, name),
        title: Text(
          name,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$date ${size.isNotEmpty ? '• $size' : ''}',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        trailing: const Icon(
          Icons.more_vert,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLeading(bool isDirectory, String name) {
    if (isDirectory) {
      return _buildIconContainer(FontAwesomeIcons.folder);
    }

    final ext = p.extension(name).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(entity.path),
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          cacheWidth: 100,
          errorBuilder: (context, error, stackTrace) => _buildIconContainer(FontAwesomeIcons.fileImage),
        ),
      );
    }

    if (['.mp4', '.mov', '.avi', '.mkv'].contains(ext)) {
      return VideoThumbnailWidget(videoPath: entity.path);
    }

    return _buildIconContainer(_getIconForFile(name));
  }

  Widget _buildIconContainer(dynamic icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(
          icon,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
      ),
    );
  }

  dynamic _getIconForFile(String name) {
    final ext = p.extension(name).toLowerCase();
    switch (ext) {
      case '.pdf':
        return FontAwesomeIcons.filePdf;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
        return FontAwesomeIcons.fileImage;
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        return FontAwesomeIcons.fileVideo;
      case '.mp3':
      case '.wav':
      case '.m4a':
        return FontAwesomeIcons.fileAudio;
      case '.zip':
      case '.rar':
      case '.7z':
      case '.tar':
        return FontAwesomeIcons.fileZipper;
      case '.txt':
      case '.md':
      case '.log':
        return FontAwesomeIcons.fileLines;
      case '.doc':
      case '.docx':
        return FontAwesomeIcons.fileWord;
      case '.xls':
      case '.xlsx':
        return FontAwesomeIcons.fileExcel;
      case '.ppt':
      case '.pptx':
        return FontAwesomeIcons.filePowerpoint;
      default:
        return FontAwesomeIcons.file;
    }
  }

  String _formatSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
