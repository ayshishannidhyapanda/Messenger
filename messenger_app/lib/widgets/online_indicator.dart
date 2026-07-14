import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Green dot to indicate online status.
class OnlineIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;

  const OnlineIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? AppTheme.success : AppTheme.onSurfaceDim,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.surface, width: 2),
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: AppTheme.success.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
