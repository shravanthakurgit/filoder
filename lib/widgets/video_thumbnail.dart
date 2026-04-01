import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String videoPath;

  const VideoThumbnailWidget({super.key, required this.videoPath});

  Future<String?> _generateThumbnail() async {
    final tempDir = await getTemporaryDirectory();
    return VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(snapshot.data!),
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          );
        }
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.video,
              color: AppTheme.primaryBlue,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}
