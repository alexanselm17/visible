import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedLoadingIndicator extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final double size;
  final Widget? child;
  final String? loadingText;
  final bool isLoading;

  const AnimatedLoadingIndicator({
    super.key,
    this.primaryColor = const Color(0xFFFF6B00),
    this.secondaryColor = Colors.white,
    this.size = 60,
    this.child,
    this.loadingText,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child ?? const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedLoader(),
          if (loadingText != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingText!,
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 600.ms)
                .then(delay: 200.ms)
                .fadeOut(duration: 600.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedLoader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulsing circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.2),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.2, 1.2),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(1.0, 1.0),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            ),

        // Core spinner
        SizedBox(
          width: size * 0.7,
          height: size * 0.7,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            backgroundColor: primaryColor.withOpacity(0.2),
            strokeWidth: 4,
          ),
        ).animate(onPlay: (controller) => controller.repeat()).rotate(
              duration: 1500.ms,
              begin: 0,
              end: 1,
              curve: Curves.easeInOut,
            ),

        // Inner dot
        Container(
          width: size * 0.25,
          height: size * 0.25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: secondaryColor,
            border: Border.all(color: primaryColor, width: 2),
          ),
        ),
      ],
    );
  }
}

class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? color;
  final double? size;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: isLoading ? 0.3 : 1.0,
          child: IgnorePointer(
            ignoring: isLoading,
            child: child,
          ),
        ),
        if (isLoading)
          AnimatedLoadingIndicator(
            isLoading: true,
            primaryColor: color ?? const Color(0xFFFF6B00),
            size: size ?? 60,
            loadingText: loadingText,
          ),
      ],
    );
  }
}
