import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import '../globals.dart';

class AnimatedCassetteWidget extends StatefulWidget {
  final String colorTheme;
  final String? photoUrl;
  final bool isPlaying;

  const AnimatedCassetteWidget({
    super.key,
    required this.colorTheme,
    this.photoUrl,
    this.isPlaying = true,
  });

  @override
  State<AnimatedCassetteWidget> createState() => _AnimatedCassetteWidgetState();
}

class _AnimatedCassetteWidgetState extends State<AnimatedCassetteWidget>
    with TickerProviderStateMixin {
  late AnimationController _reelController;
  late AnimationController _tapeController;

  @override
  void initState() {
    super.initState();
    _reelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _tapeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isPlaying) {
      _reelController.repeat();
      _tapeController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedCassetteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _reelController.repeat();
        _tapeController.repeat(reverse: true);
      } else {
        _reelController.stop();
        _tapeController.stop();
      }
    }
  }

  @override
  void dispose() {
    _reelController.dispose();
    _tapeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        CassetteThemes.themes[widget.colorTheme] ?? AppColors.amberDeep;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background color with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    Color.lerp(color, Colors.black, 0.2)!,
                  ],
                ),
              ),
            ),

            // Photo background if available
            if (widget.photoUrl != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: CachedNetworkImage(
                    imageUrl: widget.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: color.withOpacity(0.5)),
                    errorWidget: (context, url, error) =>
                        Container(color: color),
                  ),
                ),
              ),

            // Film grain effect
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: FilmGrainPainter(),
                ),
              ),
            ),

            // Cassette body
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Label area
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.sepia.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '♪  CassetteNote  ♪',
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brownDark,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reels and tape section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _reelController,
                        builder: (context, child) =>
                            _buildReel(_reelController.value),
                      ),
                      const SizedBox(width: 12),
                      _buildTapeStrip(),
                      const SizedBox(width: 12),
                      AnimatedBuilder(
                        animation: _reelController,
                        builder: (context, child) =>
                            _buildReel(_reelController.value),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Viewing window for tape
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.brownDark.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AnimatedBuilder(
                      animation: _tapeController,
                      builder: (context, child) => CustomPaint(
                        painter: TapeStripPainter(_tapeController.value),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Shine effect
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReel(double rotation) {
    return Transform.rotate(
      angle: rotation * 2 * math.pi,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.brownDark,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warmWhite, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Center hub
            Center(
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.brownDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sepia, width: 2),
                ),
              ),
            ),
            // Spokes
            ...List.generate(6, (index) {
              return Transform.rotate(
                angle: (index * math.pi / 3),
                child: Center(
                  child: Container(
                    width: 2,
                    height: 55,
                    color: AppColors.sepia.withOpacity(0.5),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTapeStrip() {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.brownDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: _tapeController,
        builder: (context, child) {
          return CustomPaint(
            painter: TapeDetailPainter(_tapeController.value),
          );
        },
      ),
    );
  }
}

// Custom painter for film grain effect
class FilmGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final random = math.Random(42); // Fixed seed for consistent grain

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for moving tape strips in the window
class TapeStripPainter extends CustomPainter {
  final double progress;

  TapeStripPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brownMid.withOpacity(0.6)
      ..strokeWidth = 2;

    // Draw horizontal lines that move
    for (int i = 0; i < 8; i++) {
      final y = (i * 6.0 + progress * 6) % size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TapeStripPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom painter for tape detail effects
class TapeDetailPainter extends CustomPainter {
  final double progress;

  TapeDetailPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sepia.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw vertical lines for tape texture
    for (double x = 0; x < size.width; x += 3) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Add shimmer effect
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.1 + progress * 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TapeDetailPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
