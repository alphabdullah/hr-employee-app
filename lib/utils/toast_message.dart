import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../resources/app_colors.dart';
import 'screen_unit_util.dart';

/// Toast Message Utility
/// Provides methods to show flushbar messages with different types
class ToastMessage {
  /// Show error message
  static void showError(String message, BuildContext context) {
    _showFlushbar(
      context: context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      iconColor: Colors.white,
    );
  }

  /// Show success message
  static void showSuccess(String message, BuildContext context) {
    _showFlushbar(
      context: context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
      iconColor: Colors.white,
    );
  }

  /// Show warning message
  static void showWarning(String message, BuildContext context) {
    _showFlushbar(
      context: context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_outlined,
      iconColor: Colors.white,
    );
  }

  /// Show info message
  static void showInfo(String message, BuildContext context) {
    _showFlushbar(
      context: context,
      message: message,
      backgroundColor: AppColors.secondary,
      icon: Icons.info_outline,
      iconColor: Colors.white,
    );
  }

  /// Generic flushbar message (matches your example pattern)
  static void flushbarMessage(String message, BuildContext context) {
    _showFlushbar(
      context: context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error,
      iconColor: Colors.white,
    );
  }

  /// Internal method to show flushbar
  static void _showFlushbar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    String? title,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    // Initialize ScreenUnitUtil if not already initialized
    try {
      ScreenUnitUtil.init(context);
    } catch (e) {
      // Already initialized, ignore
    }

    Flushbar(
      message: message,
      title: title,
      backgroundColor: backgroundColor,
      messageColor: Colors.white,
      titleColor: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
      margin: EdgeInsets.all(ScreenUnitUtil.getSpacing(10)),
      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(15)),
      flushbarPosition: position,
      positionOffset: ScreenUnitUtil.getHeight(60),
      borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
      icon: Icon(
        icon,
        color: iconColor,
        size: ScreenUnitUtil.getFontSize(24),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: ScreenUnitUtil.getFontSize(14),
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    )..show(context);
  }
}

