import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class DateFormatUtils {
  // Format a DateTime to a readable format (e.g., "9-10-2024")
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }


  static String formatHijriDate(DateTime date){
    final hDate = HijriCalendar.fromDate(date);
    late final  String hijriMonth;

    // adjusting values based on the client's requests
    switch (hDate.longMonthName) {
      case 'ربيع الثاني':
        hijriMonth = "ربيع الاخر";
        break;
      case 'جمادى الثاني':
        hijriMonth = 'جمادى الاخرة';
        break;
      default:
        hijriMonth = hDate.longMonthName;
    }

    return "${hDate.hDay} $hijriMonth ${hDate.hYear} هـ";
  }

  // Format a DateTime to a specific pattern
  static String formatWithPattern(DateTime date, String pattern) {
    final DateFormat formatter = DateFormat(pattern);
    return formatter.format(date);
  }

}
