import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final bool isOverlay;

  const LoadingIndicator({
    super.key,
    this.message = AppStrings.loadingMessage,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 64,
              width: 64,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            Icon(
              Icons.healing_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (isOverlay) {
      return Container(
        color: theme.colorScheme.surface.withOpacity(0.8),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(AppConstants.paddingL),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: indicator,
            ),
          ),
        ),
      );
    }

    return Center(child: indicator);
  }
}
