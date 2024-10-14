import 'package:intl/intl.dart';

class DateFormatUtils {
  // Format a DateTime to a readable format (e.g., "9-10-2024")
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  // Format a DateTime to a specific pattern
  static String formatWithPattern(DateTime date, String pattern) {
    final DateFormat formatter = DateFormat(pattern);
    return formatter.format(date);
  }
}

class HijriFormatUtils {
  
}
