// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// Distinguishes whether this item is a normal checklist item or a prayer item.
enum ChecklistItemType {
  normal,
  prayer,
}

/// Represents days of the week.
enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

DayOfWeek getDayOfWeekBasedOnPackage(int index) {

  switch (index) {
    case 1:
      return DayOfWeek.monday;
    case 2:
      return DayOfWeek.tuesday;
    case 3:
      return DayOfWeek.wednesday;
    case 4:
      return DayOfWeek.thursday;
    case 5:
      return DayOfWeek.friday;
    case 6:
      return DayOfWeek.saturday;
    case 7:
      return DayOfWeek.sunday;
  }
  return DayOfWeek.values[index];
}

/// Enum representing prayer completion status.
enum PrayerDoneType {
  ontimeGroup,
  ontime,
  late,
  missed,
  excused
}



/// A unified checklist item that can represent either a 'normal' item or a 'prayer' item.
/// Some items can be repeated daily (`isPermanent == true`), or specific to certain days.
class ChecklistItem {
  final String id;
  final String displayName;
  final ChecklistItemType itemType;

  int? index; // For sorting

  // For a normal “checkable” item
  bool? isChecked;

  // For prayer items only
  PrayerDoneType? prayerDoneType;   
  
  // Whether it repeats daily or not
  final bool isPermanent;

  // If not permanent, is it for a specific day of week?
  // (You can make this a List<DayOfWeek> if you want multiple days.)
  final List<DayOfWeek>? daysOfWeek;

  // Or is it a one-off date? (Optional, can be null)
  final DateTime? date;



  ChecklistItem({
    required this.id,
    required this.displayName,
    required this.itemType,
    required this.isPermanent,
    this.index,
    this.isChecked,
    this.daysOfWeek,
    this.date,
    this.prayerDoneType,
  });

  /// Construct from Firestore document data.
  factory ChecklistItem.fromFirestore(Map<String, dynamic> data) {
    // Parse the checklist item type
    final itemTypeString = data['itemType'] as String? ?? 'normal';
    final itemType = ChecklistItemType.values.firstWhere(
      (e) => e.toString().split('.').last == itemTypeString,
      orElse: () => ChecklistItemType.normal,
    );

    // Parse dayOfWeek (if present). Store it as an int in Firestore, for example.
    List<DayOfWeek>? _daysOfWeek;
    final daysOfWeekIndices = data['daysOfWeek'] as List<dynamic>?;
    if (daysOfWeekIndices != null) {
      _daysOfWeek = daysOfWeekIndices.map((index) => DayOfWeek.values[int.parse(index)]).toList();
    }

    // Parse prayerDoneType if itemType == prayer
    PrayerDoneType? prayerDoneType;
    if (itemType == ChecklistItemType.prayer && data['prayerDoneType'] != null) {
      final prayerTypeString = data['prayerDoneType'] as String;
      prayerDoneType = PrayerDoneType.values.firstWhere(
        (e) => e.toString().split('.').last == prayerTypeString,
        orElse: () => PrayerDoneType.missed,
      );
    }

    return ChecklistItem(
      id: data['id'] ?? '',
      displayName: data['displayName'] ?? '',
      itemType: itemType,
      index: data['index'] as int?,
      isPermanent: data['isPermanent'] as bool? ?? false,
      isChecked: data['isChecked'] as bool?,
      daysOfWeek: _daysOfWeek,
      date: (data['date'] != null)
          ? (data['date'] as Timestamp).toDate()
          : null,
      prayerDoneType: prayerDoneType,
    );
  }

  /// Convert to a map for Firestore.
  Map<String, dynamic> toFirestore() {
    final dOW = daysOfWeek?.map((item) => item.index).toList();
    return {
      'id': id,
      'displayName': displayName,
      'itemType': itemType.toString().split('.').last,
      'index': index,
      'isPermanent': isPermanent,
      'isChecked': isChecked,
      'daysOfWeek': dOW,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'prayerDoneType': prayerDoneType?.toString().split('.').last,
    };
  }

  static String generateItemId() {
    String start = DateTime.now().microsecondsSinceEpoch.toString();
    final bytes = utf8.encode(start); // Encode input as bytes
    final hash = sha256.convert(bytes); // Create SHA-256 hash
    String id = hash.toString().substring(0, 5).toUpperCase(); // Truncate and uppercase
    return 'Item_$id';
  }
}

/// A class representing a checklist.
class Checklist {
  /// The ID of the user associated with the checklist.
  final String userId;

  /// The date of the checklist.
  final DateTime date;

  /// The list of checklist items.
  final List<ChecklistItem> items;

  /// The score of the checklist.
  final int score;
 
  /// Creates a new [Checklist].
  ///
  /// The [userId], [date], [items], and [prayers] parameters are required.
  Checklist({
    required this.userId,
    required this.date,
    required this.items,
    required this.score
  });

  /// Creates a new [Checklist] from Firestore data.
  ///
  /// The [data] parameter is a map containing the Firestore data.
  factory Checklist.fromFirestore(Map<String, dynamic> data) {
    return Checklist(
      userId: data['userId'] ?? '',
      date: DateFormatUtils.parseDate(data['date'] as String),
      items: (data['items'] as List)
          .map((item) => ChecklistItem.fromFirestore(item))
          .toList(),
      score: data['score'] ?? 0,
    );
  }

  /// Converts the [Checklist] to a map suitable for Firestore.
  ///
  /// Returns a map containing the Firestore data.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': DateFormatUtils.formatDate(date),
      'items': items.map((item) => item.toFirestore()).toList(),
      'score': score
    };
  }
}