import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../globals.dart';

class CassetteWidget extends StatelessWidget {
  final String colorTheme;
  final String? photoUrl;

  const CassetteWidget({super.key, required this.colorTheme, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final color = CassetteThemes.themes[colorTheme] ?? AppColors.amberDeep;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Photo as background if available
          if (photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: photoUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
              ),
            ),

          // Cassette overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cassette emoji
                const Text('📼', style: TextStyle(fontSize: 100)),

                const SizedBox(height: 16),

                // Cassette reels (simple representation)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildReel(),
                    const SizedBox(width: 40),
                    _buildReel(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReel() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.brownDark,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.warmWhite, width: 2),
      ),
      child: Center(
        child: Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: AppColors.brownDark,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sepia, width: 1),
          ),
        ),
      ),
    );
  }
}
