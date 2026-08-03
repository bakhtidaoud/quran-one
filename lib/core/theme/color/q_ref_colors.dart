import 'package:flutter/material.dart';

/// Raw reference palette. Imported by exactly one file
/// (q_color_schemes.dart), enforced by lint.
///
/// No gold anywhere in this palette. Gold is what every competitor reaches
/// for and it reads as decorative rather than reverent.
abstract final class QRef {
  // Primary - "Mihrab". 10.0:1 on the light canvas.
  static const primary = Color(0xFF1F4A3C);
  static const primaryDark = Color(0xFF7FB8A2);
  static const onPrimaryDark = Color(0xFF00382A);
  static const primaryContainerLight = Color(0xFFA8D5C4);
  static const onPrimaryContainerLight = Color(0xFF002019);
  static const primaryContainerDark = Color(0xFF2B5C4C);
  static const primaryContainerAmoled = Color(0xFF1A3A30);
  static const onPrimaryContainerDark = Color(0xFFC4EBD9);

  // Secondary - "Sabr".
  static const secondary = Color(0xFF8A6F4E);
  static const secondaryTextLight = Color(0xFF6B563C);
  static const secondaryDark = Color(0xFFC9AE8B);
  static const onSecondaryDark = Color(0xFF3A2C18);
  static const secondaryContainerLight = Color(0xFFEADDCB);
  static const onSecondaryContainerLight = Color(0xFF241A0C);
  static const secondaryContainerDark = Color(0xFF4A3A22);
  static const secondaryContainerAmoled = Color(0xFF33270F);
  static const onSecondaryContainerDark = Color(0xFFEFDDC4);

  // Accent - "Sidr".
  static const accent = Color(0xFFB4552F);
  static const accentDark = Color(0xFFE0906B);
  static const onAccentDark = Color(0xFF44200E);

  // Tertiary / info - "Layl".
  static const tertiary = Color(0xFF2A5C82);
  static const tertiaryDark = Color(0xFF9BC4E8);
  static const onTertiaryDark = Color(0xFF0B2E45);
  static const tertiaryContainerLight = Color(0xFFCFE4F5);
  static const onTertiaryContainerLight = Color(0xFF06131E);
  static const tertiaryContainerDark = Color(0xFF1E4462);
  static const tertiaryContainerAmoled = Color(0xFF13293A);
  static const onTertiaryContainerDark = Color(0xFFD3E6F7);

  // Status.
  static const success = Color(0xFF2D6A4F);
  static const successDark = Color(0xFF7EC8A0);
  static const warning = Color(0xFF8A5A00);
  static const warningDark = Color(0xFFE0B65C);
  static const error = Color(0xFF8C1D18);
  static const errorDark = Color(0xFFF2B8B5);
  static const onErrorDark = Color(0xFF601410);
  static const errorContainerLight = Color(0xFFF9DEDC);
  static const onErrorContainerLight = Color(0xFF410E0B);
  static const errorContainerDark = Color(0xFF8C1D18);
  static const errorContainerAmoled = Color(0xFF5C1512);

  // Light neutrals. Warm canvas, never pure white: paper, not a screen.
  static const bgLight = Color(0xFFFBF8F3);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF1EBE1);
  static const dividerLight = Color(0xFFE6E0D6);
  static const borderStrongLight = Color(0xFF8F877A);
  static const textLight = Color(0xFF16181C);
  static const textMutedLight = Color(0xFF5A5D63);
  static const textFaintLight = Color(0xFF7A7D83);
  static const disabledLight = Color(0xFF8B8E94);
  static const iconLight = Color(0xFF3A3D42);
  static const inverseSurfaceLight = Color(0xFF2E312F);
  static const onInverseSurfaceLight = Color(0xFFF1EFEC);

  // Dark neutrals.
  static const bgDark = Color(0xFF14161A);
  static const surfaceDark = Color(0xFF1A1D22);
  static const cardDark = Color(0xFF212429);
  static const dividerDark = Color(0xFF262A30);
  static const borderStrongDark = Color(0xFF3A3F47);
  static const textDark = Color(0xFFE4E1DC);
  static const textMutedDark = Color(0xFFA8A5A0);
  static const textFaintDark = Color(0xFF7E7B77);
  static const disabledDark = Color(0xFF66635F);
  static const iconDark = Color(0xFFCFCCC7);

  // AMOLED neutrals. Ink is never pure white: on a true black panel it
  // haloes and fatigues the eye during long reading.
  static const bgAmoled = Color(0xFF000000);
  static const surfaceAmoled = Color(0xFF0A0A0B);
  static const cardAmoled = Color(0xFF0E0F11);
  static const dividerAmoled = Color(0xFF161616);
  static const borderStrongAmoled = Color(0xFF2A2A2C);
  static const textAmoled = Color(0xFFD9D6D1);
  static const textMutedAmoled = Color(0xFFA3A09B);
  static const textFaintAmoled = Color(0xFF78756F);
  static const disabledAmoled = Color(0xFF605D59);
  static const iconAmoled = Color(0xFFC6C3BE);
}
