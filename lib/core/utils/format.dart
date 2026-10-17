import 'jalali.dart';

/// Replaces ASCII digits with Persian digits.
String faDigits(Object? input) {
  const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  return input.toString().replaceAllMapped(
        RegExp(r'[0-9]'),
        (m) => fa[int.parse(m[0]!)],
      );
}

String _two(int v) => v.toString().padLeft(2, '0');

/// e.g. ۱۴۰۵/۰۷/۲۳ — ۱۴:۰۵:۰۹ (Jalali date, local time).
String formatJalaliDateTime(DateTime t) {
  final local = t.toLocal();
  final j = gregorianToJalali(local.year, local.month, local.day);
  return faDigits(
      '${j[0]}/${_two(j[1])}/${_two(j[2])} — ${_two(local.hour)}:${_two(local.minute)}:${_two(local.second)}');
}

/// Human readable relative time in Persian.
String formatRelative(DateTime t, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(t);
  if (diff.inSeconds < 5) return 'همین الان';
  if (diff.inSeconds < 60) return '${faDigits(diff.inSeconds)} ثانیه پیش';
  if (diff.inMinutes < 60) return '${faDigits(diff.inMinutes)} دقیقه پیش';
  if (diff.inHours < 24) return '${faDigits(diff.inHours)} ساعت پیش';
  return '${faDigits(diff.inDays)} روز پیش';
}
