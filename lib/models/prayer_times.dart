class PrayerTime {
  final String date;
  final String fajr;
  final String shuruq;
  final String duhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTime({
    required this.date,
    required this.fajr,
    required this.shuruq,
    required this.duhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  Map<String, dynamic> toMap() {
    return {
      'Fajr': fajr,
      'Shuruq': shuruq,
      'Duhr': duhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }

}