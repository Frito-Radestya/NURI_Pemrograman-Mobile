import 'package:intl/intl.dart';

String formatDateId(
  DateTime date, {
  bool withYear = true,
  bool shortMonth = false,
}) {
  final pattern = shortMonth
      ? (withYear ? 'd MMM yy' : 'd MMM')
      : (withYear ? 'd MMMM yyyy' : 'd MMMM');
  return DateFormat(pattern, 'id_ID').format(date);
}

String formatMonthYear(DateTime date) =>
    DateFormat('MMMM yyyy', 'id_ID').format(date);

String formatDayShort(DateTime date) => DateFormat('EEE', 'id_ID').format(date);

String formatWeekday(DateTime date) => DateFormat('EEEE', 'id_ID').format(date);

String formatTime(DateTime date) => DateFormat('HH:mm', 'id_ID').format(date);

String relativeDayLabel(DateTime date, {DateTime? now}) {
  final today = DateTime(
    (now ?? DateTime.now()).year,
    (now ?? DateTime.now()).month,
    (now ?? DateTime.now()).day,
  );
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Besok';
  if (diff == -1) return 'Kemarin';
  return formatDateId(date, withYear: false);
}

String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'N';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
  return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
}

String compactNumber(double? value) {
  if (value == null) return '—';
  if (value >= 1000) {
    final thousands = value / 1000;
    return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}k';
  }
  return value.round().toString();
}

String gramsLabel(double grams) {
  if (grams == grams.roundToDouble()) return '${grams.round()} g';
  return '${grams.toStringAsFixed(1)} g';
}

String percentLabel(double? percent) =>
    percent == null ? '—' : '${percent.round()}%';
