import 'package:intl/intl.dart';

/// Shared TZS formatter — thousands separators, no decimals (shillings
/// aren't traded in fractions in practice). Same pattern the dashboard
/// already used; every other screen that shows a money amount should
/// go through this instead of `toStringAsFixed(0)` so `8000` reads as
/// `TZS 8,000`.
final _currencyFormat =
    NumberFormat.currency(locale: 'en_TZ', symbol: 'TZS ', decimalDigits: 0);
final _numberFormat = NumberFormat.decimalPattern('en_TZ');

String formatTzs(num value) => _currencyFormat.format(value);

/// Same thousands-grouping, no currency symbol — for amounts already
/// paired with their own "TZS" label or shown in a non-money context
/// (e.g. quantities) where only the grouping is wanted.
String formatAmount(num value) => _numberFormat.format(value);

/// Compact form for tight spaces like chart axis labels — 1.2M, 850K.
String formatCompactAmount(num value) {
  final abs = value.abs();
  if (abs >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(abs % 1000000 == 0 ? 0 : 1)}M';
  }
  if (abs >= 1000) {
    return '${(value / 1000).toStringAsFixed(abs % 1000 == 0 ? 0 : 1)}K';
  }
  return value.toStringAsFixed(0);
}
