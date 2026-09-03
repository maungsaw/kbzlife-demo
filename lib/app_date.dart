import 'package:intl/intl.dart';

/// Doc 94 — one canonical date pattern (`dd-MMM-yyyy`) across the app,
/// always English months regardless of UI locale. Doc 95 — 12-hour padded
/// clock (`01:00 PM`) for task timelines.
class AppDate {
  AppDate._();

  static final _dMy = DateFormat('dd-MMM-yyyy', 'en_US');
  static final _dMyHm = DateFormat('dd-MMM-yyyy hh:mm a', 'en_US');
  static final _hm = DateFormat('hh:mm a', 'en_US');
  static final _monthYear = DateFormat('MMMM yyyy', 'en_US');

  static String dMy(DateTime dt) => _dMy.format(dt);
  static String dMyHm(DateTime dt) => _dMyHm.format(dt);

  /// 12-hour padded clock, e.g. `01:00 PM`, `09:00 AM`, `12:00 AM`.
  static String h12(DateTime dt) => _hm.format(dt);

  static String h12Hour(int hour24, {int minute = 0}) => _hm.format(DateTime(2000, 1, 1, hour24, minute));

  static String range(DateTime a, DateTime b) => '${dMy(a)} - ${dMy(b)}';

  /// Full month name + year, e.g. `August 2026` — Month view header.
  static String monthYear(DateTime dt) => _monthYear.format(dt);
}
