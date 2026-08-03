import 'package:flutter/material.dart';
import 'package:quran_one/core/i18n/numerals.dart';
import 'package:quran_one/core/theme/theme_context.dart';
import 'package:quran_one/features/home/presentation/controllers/countdown.dart';

/// The one element on Home that is always present and never moves.
///
/// Roughly eight openings a day, about four seconds each, and in the
/// overwhelming majority of them the user wants a single fact: how long
/// until the next prayer. Everything on this card exists to answer that
/// before it decorates anything.
///
/// Order is deliberate: name, relative time, absolute time. Relative
/// first because it needs no arithmetic. Absolute second because people
/// schedule around it.
class QPrayerCard extends StatelessWidget {
  const QPrayerCard({
    required this.countdown,
    required this.onTap,
    super.key,
  });

  final Countdown countdown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final numerals = NumeralSystem.forLocale(Localizations.localeOf(context));

    return Semantics(
      button: true,
      // One utterance, not four. A screen reader user should hear the
      // whole answer without arrowing through four separate nodes.
      label: _semanticLabel(context, numerals),
      excludeSemantics: true,
      child: Material(
        color: colors.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: context.shape.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: context.shape.card,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PrayerName(
                  prayer: countdown.prayer,
                  colour: colors.onPrimaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  countdown.isNow
                      ? _nowLabel(context)
                      : _relative(countdown, numerals),
                  // Never .toUpperCase(): it destroys Arabic and Urdu.
                  style: text.displaySmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  numerals.formatTime(countdown.at),
                  style: text.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.72),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (countdown.showsElapsed) ...[
                  const SizedBox(height: 14),
                  // Current prayer status is one muted line, not a
                  // second card. The only reason to surface elapsed
                  // time is the worry of having missed one, and that is
                  // answered in six words.
                  Text(
                    _elapsed(context, countdown, numerals),
                    style: text.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(BuildContext context, NumeralSystem numerals) {
    final buffer = StringBuffer(countdown.prayer.name.toUpperCase());
    // The name is the one exception to the no-uppercase rule: it is a
    // proper noun in Latin script and is never localised.
    if (countdown.isNow) {
      buffer.write(', now');
    } else {
      buffer.write(', in ${_spokenRelative(countdown.remaining)}');
    }
    buffer.write(', at ${numerals.formatTime(countdown.at)}');
    if (countdown.showsElapsed) {
      buffer.write('. ${_elapsed(context, countdown, numerals)}');
    }
    return buffer.toString();
  }
}

class _PrayerName extends StatelessWidget {
  const _PrayerName({required this.prayer, required this.colour});

  final Prayer prayer;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          _arabic[prayer]!,
          textDirection: TextDirection.rtl,
          style: context.text.titleMedium?.copyWith(
            color: colour.withValues(alpha: 0.78),
            fontFamily: context.text.titleMedium?.fontFamily,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          prayer.name.toUpperCase(),
          style: context.text.labelLarge?.copyWith(
            color: colour.withValues(alpha: 0.78),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  static const _arabic = <Prayer, String>{
    Prayer.fajr: '\u0627\u0644\u0641\u062C\u0631',
    Prayer.dhuhr: '\u0627\u0644\u0638\u0647\u0631',
    Prayer.asr: '\u0627\u0644\u0639\u0635\u0631',
    Prayer.maghrib: '\u0627\u0644\u0645\u063A\u0631\u0628',
    Prayer.isha: '\u0627\u0644\u0639\u0634\u0627\u0621',
  };
}

String _relative(Countdown countdown, NumeralSystem numerals) {
  final d = countdown.remaining;
  switch (countdown.precision) {
    case CountdownPrecision.hoursMinutes:
      final h = numerals.format(d.inHours);
      final m = numerals.format(d.inMinutes.remainder(60));
      return 'in ${h}h ${m}m';
    case CountdownPrecision.minutes:
      return 'in ${numerals.format(d.inMinutes)}m';
    case CountdownPrecision.minutesSeconds:
      final m = numerals.format(d.inMinutes);
      final s = numerals.format(d.inSeconds.remainder(60)).padLeft(2, '0');
      return 'in $m:$s';
    case CountdownPrecision.now:
      return 'now';
  }
}

String _spokenRelative(Duration d) {
  if (d.inHours > 0) {
    return '${d.inHours} hours ${d.inMinutes.remainder(60)} minutes';
  }
  return '${d.inMinutes} minutes';
}

String _nowLabel(BuildContext context) => 'now';

String _elapsed(
  BuildContext context,
  Countdown countdown,
  NumeralSystem numerals,
) {
  final since = countdown.sincePrevious!;
  final name = countdown.previousPrayer!.name;
  final capitalised = name[0].toUpperCase() + name.substring(1);
  if (since.inHours >= 1) {
    return '$capitalised passed ${numerals.format(since.inHours)}h ago';
  }
  return '$capitalised passed ${numerals.format(since.inMinutes)}m ago';
}
