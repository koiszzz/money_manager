import 'package:intl/intl.dart';

class Formatters {
  static String currencySymbol(String code, String locale) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'CNY':
        return '¥';
      case 'EUR':
        return '€';
      default:
        return locale.startsWith('zh') ? '¥' : '\$';
    }
  }

  static NumberFormat _currency(
    String locale, {
    String currencyCode = 'CNY',
    int decimalDigits = 2,
  }) {
    final symbol = currencySymbol(currencyCode, locale);
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
  }

  static String money(
    double value, {
    bool showSign = false,
    String locale = 'zh_CN',
    String currencyCode = 'CNY',
    int decimalDigits = 2,
  }) {
    final formatted = _currency(
      locale,
      currencyCode: currencyCode,
      decimalDigits: decimalDigits,
    ).format(value.abs());
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
