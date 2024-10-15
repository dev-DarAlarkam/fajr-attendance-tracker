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
    return "${hDate.hDay} ${hDate.shortMonthName} ${hDate.hYear} هـ";
  }

  // Format a DateTime to a specific pattern
  static String formatWithPattern(DateTime date, String pattern) {
    final DateFormat formatter = DateFormat(pattern);
    return formatter.format(date);
  }

}



class HijriFormatUtils {
  

}
