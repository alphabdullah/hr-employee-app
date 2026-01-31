import 'package:flutter/material.dart';
import '../../utils/screen_unit_util.dart';

/// Primary Button Component
/// Reusable button for Login, SignUp, and other primary actions
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width,
      height: height ?? ScreenUnitUtil.getHeight(56),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                width: ScreenUnitUtil.getFontSize(20),
                height: ScreenUnitUtil.getFontSize(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: ScreenUnitUtil.getFontSize(20),
                        color: foregroundColor ?? theme.colorScheme.onPrimary,
                      ),
                      SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}

