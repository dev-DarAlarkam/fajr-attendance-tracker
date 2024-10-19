// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

class PrayerTimesManager {
  final String timezoneApiUrl = "https://worldtimeapi.org/api/timezone/Asia/Jerusalem";
  final String xmlPath = "lib/assets/xml/prayers.xml";
  final Map<String, Map<String, DateTime>> _prayerTimes = {};

  DateTime? dstStart;
  DateTime? dstEnd;

  PrayerTimesManager();


  Future<void> initialize() async {
    await _fetchDSTInfo();
    await _parseXml();
  }

  Future<void> _fetchDSTInfo() async {
    final response = await http.get(Uri.parse(timezoneApiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      dstStart = DateTime.parse(data['dst_from']);
      dstEnd = DateTime.parse(data['dst_until']);
    } else {
      throw Exception('Failed to fetch DST data');
    }
  }

  Future<String> _loadAsset() async {
    return await rootBundle.loadString(xmlPath);
  }

  Future<void> _parseXml() async {
    final xmlData = await _loadAsset();
    final document = XmlDocument.parse(xmlData);
    final items = document.findAllElements('item');

    for (var item in items) {
      final dateString = item.findElements('Date').single.text;
      final date = _parseDate(dateString);

      _prayerTimes[dateString] = {
        'Fajr': _parseTime(item.findElements('Fajr').single.text, date),
        'Shuruq': _parseTime(item.findElements('Shuruq').single.text, date),
        'Duhr': _parseTime(item.findElements('Duhr').single.text, date),
        'Asr': _parseTime(item.findElements('Asr').single.text, date),
        'Maghrib': _parseTime(item.findElements('Maghrib').single.text, date),
        'Isha': _parseTime(item.findElements('Isha').single.text, date),
      };
    }
  }

  DateTime _parseDate(String date) {
    final dateFormat = DateFormat('MM.dd');
    return dateFormat.parse(date);
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


  Future<Map<String, DateTime>?> getTodaysPrayerTimes() async {
    if (dstStart == null || dstEnd == null || _prayerTimes.isEmpty) {
      await initialize(); // Initialize if needed
    }
    
    final today = DateFormat('MM.dd').format(DateTime.now());
    final times = _prayerTimes[today];

    if (times == null) return null;

    if (_isDST(DateTime.now())) {
      return times.map((key, time) => MapEntry(key, time.add(Duration(hours: 1))));
    }
    return times;
  }

  Future<bool> isItFajrTime() async {
    Map<String,DateTime>? prayers = await getTodaysPrayerTimes();

    if(prayers != null) {
      DateTime now = DateTime.now();

      if(now.isAfter(prayers['Fajr']!) && now.isBefore(prayers['Shuruq']!)) {
        return true;
      }
    }
    return false;
  }

  bool _isDST(DateTime date) {
    if (dstStart == null || dstEnd == null) return false;
    return date.isAfter(dstStart!) && date.isBefore(dstEnd!);
  }
}
