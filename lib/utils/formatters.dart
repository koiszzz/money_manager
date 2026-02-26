import 'package:intl/intl.dart';

class Formatters {
  static NumberFormat _currency(String locale) {
    final symbol = locale.startsWith('zh') ? '¥' : '\$';
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    );
  }

  static String money(
    double value, {
    bool showSign = false,
    String locale = 'zh_CN',
  }) {
    final formatted = _currency(locale).format(value.abs());
    if (!showSign) return formatted;
    if (value > 0) return '+$formatted';
    if (value < 0) return '-$formatted';
    return formatted;
  }

  static String monthLabel(DateTime month, {String locale = 'zh_CN'}) {
    if (locale.startsWith('zh')) {
      return '${month.year}年${month.month.toString().padLeft(2, '0')}月';
    }
    return DateFormat('MMMM yyyy', locale).format(month);
  }

  static String dateLabel(DateTime date, {String locale = 'zh_CN'}) {
    if (locale.startsWith('zh')) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    return DateFormat('MMM d, yyyy', locale).format(date);
  }

  static String timeLabel(DateTime date, {String locale = 'zh_CN'}) {
    if (locale.startsWith('zh')) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return DateFormat('h:mm a', locale).format(date);
  }
}
