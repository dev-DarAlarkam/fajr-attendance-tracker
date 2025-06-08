import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CounterServices {

  Future<void> incrementGlobalCounter() async {
    String date = DateFormatUtils.formatDate(DateTime.now());
    
    DocumentReference counterDoc = FirebaseFirestore.instance.collection('counter').doc('global');
    await counterDoc.set({date: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> incrementGroupCounter(String groupId) async {
    String date = DateFormatUtils.formatDate(DateTime.now());
    
    DocumentReference counterDoc = FirebaseFirestore.instance.collection('counter').doc(groupId);
    await counterDoc.set({date: FieldValue.increment(1)}, SetOptions(merge: true));
  }
}