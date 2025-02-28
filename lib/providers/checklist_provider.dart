import 'package:attendance_tracker/providers/checklist_item_provider.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/checklist.dart';

class ChecklistProvider with ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChecklistItemProvider checklistItemProvider;

  ChecklistProvider({required this.checklistItemProvider});
  

  // Check if an checklist record exists for a specific date
  Future<bool> checklistExists(String userId, DateTime date) async {
    try {
      String checklistId = DateFormatUtils.formatDate(date);
      DocumentReference checklistDoc = _firestore.collection('users').doc(userId).collection('checklists').doc(checklistId);
      
      DocumentSnapshot docSnapshot = await checklistDoc.get();
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check checklist record: $e');
    }
  }

  Future<Checklist> getTodaysChecklist(String userId) async {
    try {
      String checklistId = DateFormatUtils.formatDate(DateTime.now());
      DocumentReference checklistDoc = _firestore.collection('users').doc(userId).collection('checklists').doc(checklistId);
      
      DocumentSnapshot docSnapshot = await checklistDoc.get();
      if (docSnapshot.exists) {
        return Checklist.fromFirestore(docSnapshot.data() as Map<String, dynamic>);
      } else {

        if(checklistItemProvider.checklistItems.isEmpty) {
          await checklistItemProvider.fetchChecklistItems();
        }
        return Checklist(
          userId: userId,
          date: DateTime.now(),
          items: checklistItemProvider.checklistItems,
          score: 0,
        );
      }
    } catch (e) {
      throw Exception('Failed to get today\'s checklist: $e');
    }
  }

  // Read checklist records
  Future<List<Checklist>> fetchChecklistRecords(String userId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      QuerySnapshot snapshot = await userDoc.collection('checklists').get();
      
      return snapshot.docs.map((doc) {
        return Checklist.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch checklist records: $e');
    }
  }

  Future<void> createOrUpdateChecklist(String userId, Checklist checklist) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      String checklistId = DateFormatUtils.formatDate(checklist.date);
      
      await userDoc.collection('checklists').doc(checklistId).set(checklist.toFirestore());
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create or update checklist record: $e');
    }
  }


  // Delete checklist record
  Future<void> deletechecklist(String userId, String checklistId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      await userDoc.collection('checklists').doc(checklistId).delete();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete checklist record: $e');
    }
  }
}
