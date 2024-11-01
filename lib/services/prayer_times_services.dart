import 'package:attendance_tracker/models/prayer_times.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PrayerTimesServices {

  String _formattedDate(DateTime date) {
    return DateFormat('MM.dd').format(date);
  }
  
  DateTime _parseTime(String time, DateTime date) {
    final timeFormat = DateFormat('H:mm');
    final parsedTime = timeFormat.parse(time);

    return DateTime(
      DateTime.now().year, // Set current year
      date.month,          // Use month from parsed date
      date.day,            // Use day from parsed date
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  Future<bool> fetchDSTStatus() async {
    final snapshot = await FirebaseFirestore.instance.collection('prayerTimes').doc('dst').get();

    if(snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data['isDST'];
    }

    throw Exception("Error fetching DST status");
  }

  Future<PrayerTime?> fetchPrayerTime(DateTime date) async {
    final _date = _formattedDate(date);

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('prayerTimes').doc(_date).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return PrayerTime(
        date: _date,
        fajr: data['Fajr'],
        shuruq: data['Shuruq'],
        duhr: data['Duhr'],
        asr: data['Asr'],
        maghrib: data['Maghrib'],
        isha: data['Isha'],
      );
    }
    throw Exception("Error fetching prayers for the given date");
  }

  Future<bool> checkIfFajrTime() async {
    PrayerTime? todayPrayers = await fetchPrayerTime(DateTime.now());
    bool isDST = await fetchDSTStatus();
    

    if (todayPrayers != null) {
      DateTime now = DateTime.now();
      DateTime fajr = _parseTime(todayPrayers.fajr, now);
      DateTime shuruq = _parseTime(todayPrayers.shuruq, now);
      if (isDST) {
        fajr = fajr.add(Duration(hours: 1));
        shuruq = shuruq.add(Duration(hours: 1));
      }

      if(now.isAfter(fajr) && now.isBefore(shuruq)) {
        return true;
      }

      return false;
    }

    throw Exception("Error fetching prayer times");
  }
}
