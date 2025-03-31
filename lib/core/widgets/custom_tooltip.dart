import 'package:flutter/material.dart';
import 'package:qr_auth_app/core/theme/app_theme.dart';

class CustomTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final String? description;

  const CustomTooltip({
    super.key,
    required this.child,
    required this.message,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      textStyle: const TextStyle(color: Colors.white),
      child: description != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                const SizedBox(width: 4),
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.primaryColor.withOpacity(0.7),
                ),
              ],
            )
          : child,
    );
  }
}