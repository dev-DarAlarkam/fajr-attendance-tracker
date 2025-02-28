import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/checklist.dart';

class ChecklistItemProvider with ChangeNotifier {
  
  ChecklistItemProvider() {
    fetchChecklistItems();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChecklistItem> _checklistItems = [];

  List<ChecklistItem> get checklistItems => _checklistItems;

  // Create checklist item
  Future<void> createChecklistItem(ChecklistItem item) async {
    try {
      await _firestore.collection('checklistItems').doc(item.id).set(item.toFirestore());
      _checklistItems.add(item);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create checklist item: $e');
    }
  }

  // Read checklist items
  Future<void> fetchChecklistItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('checklistItems').get();
      _checklistItems = snapshot.docs.map((doc) {
        return ChecklistItem.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch checklist records: $e');
    }
  }

  Future<void> createOrUpdateChecklistItem(String docId, ChecklistItem item) async {
    try {
      await _firestore.collection('checklistItems').doc(docId).set(item.toFirestore());
      int index = _checklistItems.indexWhere((element) => element.id == docId);
      if (index != -1) {
        _checklistItems[index] = item;
      } else {
        _checklistItems.add(item);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create or update checklist record: $e');
    }
  }

  Future<void> createOrpdateChecklistItemsInBulk(List<ChecklistItem> items) async {
    try {
      for (var item in items) {
        await _firestore.collection('checklistItems').doc(item.id).set(item.toFirestore());
      }
      _checklistItems = items;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update checklist records: $e');
    }
  }

  

  // Delete checklist record
  Future<void> deleteChecklistItem(String docId) async {
    try {
      await _firestore.collection('checklistItems').doc(docId).delete();
      _checklistItems.removeWhere((item) => item.id == docId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete checklist record: $e');
    }
  }
}
