import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/color/q_ref_colors.dart';
import 'package:quran_one/core/theme/q_theme_mode.dart';

/// Colours Material 3 has no slot for.
///
/// Everything the design system needs beyond ColorScheme lives in a
/// ThemeExtension rather than being hard-coded at the call site.
@immutable
class QSemanticColors extends ThemeExtension<QSemanticColors> {
  const QSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.divider,
    required this.borderStrong,
    required this.textMuted,
    required this.textFaint,
    required this.disabled,
    required this.icon,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color divider;
  final Color borderStrong;
  final Color textMuted;
  final Color textFaint;
  final Color disabled;
  final Color icon;

  static QSemanticColors forMode(QThemeMode mode) => switch (mode) {
        QThemeMode.light => const QSemanticColors(
            success: QRef.success,
            onSuccess: Color(0xFFFFFFFF),
            warning: QRef.warning,
            onWarning: Color(0xFFFFFFFF),
            info: QRef.tertiary,
            onInfo: Color(0xFFFFFFFF),
            divider: QRef.dividerLight,
            borderStrong: QRef.borderStrongLight,
            textMuted: QRef.textMutedLight,
            textFaint: QRef.textFaintLight,
            disabled: QRef.disabledLight,
            icon: QRef.iconLight,
          ),
        QThemeMode.dark => const QSemanticColors(
            success: QRef.successDark,
            onSuccess: Color(0xFF00382A),
            warning: QRef.warningDark,
            onWarning: Color(0xFF3A2C18),
            info: QRef.tertiaryDark,
            onInfo: QRef.onTertiaryDark,
            divider: QRef.dividerDark,
            borderStrong: QRef.borderStrongDark,
            textMuted: QRef.textMutedDark,
            textFaint: QRef.textFaintDark,
            disabled: QRef.disabledDark,
            icon: QRef.iconDark,
          ),
        QThemeMode.amoled => const QSemanticColors(
            success: QRef.successDark,
            onSuccess: Color(0xFF00382A),
            warning: QRef.warningDark,
            onWarning: Color(0xFF3A2C18),
            info: QRef.tertiaryDark,
            onInfo: QRef.onTertiaryDark,
            divider: QRef.dividerAmoled,
            borderStrong: QRef.borderStrongAmoled,
            textMuted: QRef.textMutedAmoled,
            textFaint: QRef.textFaintAmoled,
            disabled: QRef.disabledAmoled,
            icon: QRef.iconAmoled,
          ),
      };

  @override
  QSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? divider,
    Color? borderStrong,
    Color? textMuted,
    Color? textFaint,
    Color? disabled,
    Color? icon,
  }) =>
      QSemanticColors(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        warning: warning ?? this.warning,
        onWarning: onWarning ?? this.onWarning,
        info: info ?? this.info,
        onInfo: onInfo ?? this.onInfo,
        divider: divider ?? this.divider,
        borderStrong: borderStrong ?? this.borderStrong,
        textMuted: textMuted ?? this.textMuted,
        textFaint: textFaint ?? this.textFaint,
        disabled: disabled ?? this.disabled,
        icon: icon ?? this.icon,
      );

  @override
  QSemanticColors lerp(ThemeExtension<QSemanticColors>? other, double t) {
    if (other is! QSemanticColors) return this;
    return QSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
    );
  }
}
