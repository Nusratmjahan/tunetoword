import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart';

class SongEmbedWidget extends StatelessWidget {
  final String songUrl;

  const SongEmbedWidget({super.key, required this.songUrl});

  String _getVideoId(String url) {
    // Extract YouTube video ID
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  Future<void> _openSong(BuildContext context) async {
    try {
      final uri = Uri.parse(songUrl);
      if (!await canLaunchUrl(uri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Cannot open this song URL. Please check the link.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open the song. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening song: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _getVideoId(songUrl);
    final thumbnailUrl = videoId.isNotEmpty
        ? 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg'
        : null;

    return GestureDetector(
      onTap: () => _openSong(context),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.brownDark,
          borderRadius: BorderRadius.circular(12),
          image: thumbnailUrl != null
              ? DecorationImage(
                  image: NetworkImage(thumbnailUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Play button
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.amberDeep,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),

            // "Tap to play" text
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Text(
                'Tap to play song',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
