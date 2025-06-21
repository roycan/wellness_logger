import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic feedback utility for enhanced user experience.
/// 
/// Provides consistent haptic feedback across the app for key user interactions.
/// Falls back gracefully on devices without vibration support.
class HapticFeedbackUtil {
  /// Light haptic feedback for button taps and selections
  static Future<void> lightImpact() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Use platform-specific light impact if available
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Silently fail if haptic feedback is not available
    }
  }

  /// Medium haptic feedback for form submissions and confirmations
  static Future<void> mediumImpact() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Use platform-specific medium impact if available
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Silently fail if haptic feedback is not available
    }
  }

  /// Heavy haptic feedback for important actions like deletions
  static Future<void> heavyImpact() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Use platform-specific heavy impact if available
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Silently fail if haptic feedback is not available
    }
  }

  /// Success feedback for completed actions
  static Future<void> success() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Double light tap for success feeling
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Silently fail if haptic feedback is not available
    }
  }

  /// Error feedback for failed actions
  static Future<void> error() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Short vibration pattern for error
        await Vibration.vibrate(duration: 200);
      }
    } catch (e) {
      // Silently fail if haptic feedback is not available
    }
  }

  /// Selection feedback for picking items
  static Future<void> selectionClick() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Silently fail if haptic feedback is not available
    }
  }
}
