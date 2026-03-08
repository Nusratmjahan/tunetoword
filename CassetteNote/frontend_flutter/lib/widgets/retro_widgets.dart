import 'package:flutter/material.dart';
import '../globals.dart';

/// A widget that displays text with a vintage paper letter effect
/// Includes ruled lines, paper texture, and handwritten-style text
class VintagePaperWidget extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const VintagePaperWidget({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          // Inner shadow effect for depth
          BoxShadow(
            color: AppColors.sepia.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: RuledLinePainter(),
        child: Container(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Red margin line indicator
              Container(
                width: 2,
                height: 20,
                color: AppColors.amberDeep.withOpacity(0.3),
                margin: const EdgeInsets.only(left: 8, bottom: 16),
              ),

              // Letter text in handwritten style
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 22,
                  height: 2.0, // Line height for ruled lines
                  color: AppColors.brownDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for ruled notebook lines
class RuledLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sepia.withOpacity(0.15)
      ..strokeWidth = 1;

    // Draw horizontal ruled lines
    final lineHeight = 44.0; // Matches text height
    for (double y = 60; y < size.height; y += lineHeight) {
      canvas.drawLine(
        Offset(32, y),
        Offset(size.width - 32, y),
        paint,
      );
    }

    // Draw red margin line
    final marginPaint = Paint()
      ..color = AppColors.amberDeep.withOpacity(0.2)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(40, 0),
      Offset(40, size.height),
      marginPaint,
    );

    // Add subtle paper texture with dots
    final texturePaint = Paint()..color = AppColors.sepia.withOpacity(0.03);

    // Use simple pattern for texture dots
    for (int i = 0; i < 50; i++) {
      final x = (i * 37 % size.width.toInt()).toDouble();
      final y = (i * 53 % size.height.toInt()).toDouble();
      canvas.drawCircle(Offset(x, y), 0.5, texturePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A retro-styled container for sections
class RetroContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const RetroContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sepia.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sepia.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          // Vintage double shadow effect
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A vintage-styled button with retro aesthetics
class VintageButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const VintageButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.amberDeep;
    final txtColor = textColor ?? AppColors.warmWhite;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color.lerp(bgColor, Colors.black, 0.2)!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              // Embossed effect
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(-1, -1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: txtColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: txtColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
