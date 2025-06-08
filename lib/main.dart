import 'dart:convert';
import 'dart:html' as html;
import 'package:attendance_tracker/models/attendace.dart';
import 'package:attendance_tracker/models/checklist.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/services/group_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';
import 'package:attendance_tracker/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Users Export',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseUsersExportPage(),
    );
  }
}

class FirebaseUsersExportPage extends StatefulWidget {
  @override
  _FirebaseUsersExportPageState createState() => _FirebaseUsersExportPageState();
}

class _FirebaseUsersExportPageState extends State<FirebaseUsersExportPage> {
  bool _isLoading = false;
  String _statusMessage = '';
  double _progress = 0;
  int _totalUsers = 0;
  int _processedUsers = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Users Export'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This tool will export all users with their "attendance" and "checklists" subcollections.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _exportUsersWithSubcollections,
              child: _isLoading
                  ? Text('Exporting...')
                  : Text('Export Users Data'),
            ),
            SizedBox(height: 16),
            if (_isLoading) ...[
              LinearProgressIndicator(value: _progress),
              SizedBox(height: 8),
              Text('Processed $_processedUsers of $_totalUsers users'),
            ],
            SizedBox(height: 16),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _exportUsersWithSubcollections() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting export process...';
      _progress = 0;
      _processedUsers = 0;
    });

    try {
      // Create an Archive object to store all the CSV files
      final archive = Archive();
      
      // Get reference to the users collection
      final CollectionReference usersCollection = 
          FirebaseFirestore.instance.collection('users');
      
      // Get all user documents
      final QuerySnapshot usersSnapshot = await usersCollection.get();
      
      if (usersSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'No users found in the database';
        });
        return;
      }

      _totalUsers = usersSnapshot.docs.length;
      setState(() {
        _statusMessage = 'Processing $_totalUsers users...';
      });

      // Process each user
      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final profile = UserProfile.fromFirestore(userDoc.data() as Map<String, dynamic>);
        final userData = profile.toFirestore();
        final userName = profile.fullName;
        
        String groupName = await GroupServices().fetchGroupName(profile.groupId);
        userData['groupName'] = groupName;

        archive.addFile(ArchiveFile('users/$userName/$groupName', 0 , []));

        // Export user data to CSV
        final userCsvData = await _convertUserDataToCsv(userId, userData);
        
        
        archive.addFile(ArchiveFile(
          'users/$userName/user_data.csv',
          userCsvData.length,
          userCsvData,
        ));
        
        // Export attendance subcollection
        final attendanceData = await _exportAttendance(
          usersCollection.doc(userId).collection('attendance')
        );


        archive.addFile(ArchiveFile(
          'users/$userName/صلاة الفجر.csv',
          attendanceData.length,
          attendanceData,
        ));
        
        // Export checklists subcollection
        final checklistsData = await _exportSubcollection(
          usersCollection.doc(userId).collection('checklists')
        );
        archive.addFile(ArchiveFile(
          'users/$userName/المحاسبة.csv',
          checklistsData.length,
          checklistsData,
        ));
        
        // Update progress
        _processedUsers++;
        setState(() {
          _progress = _processedUsers / _totalUsers;
          _statusMessage = 'Processed $_processedUsers of $_totalUsers users';
        });
      }
      
      // Create a zip file from the archive
      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        throw Exception('Failed to create zip file');
      }
      
      // Trigger download
      final blob = html.Blob([zipData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'users_export.zip')
        ..click();
      
      // Clean up
      html.Url.revokeObjectUrl(url);
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Export completed successfully! $_totalUsers users exported.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
      print('Export error: $e');
    }
  }

  Future<List<int>> _convertUserDataToCsv(String userId, Map<String, dynamic> userData) async {
    // Extract field names (headers) from the user data
    final List<String> headers = ['user_id', ...userData.keys.toList()];
    
    // Prepare rows for CSV
    List<List<dynamic>> rows = [];
    
    // Add header row
    rows.add(headers);
    
    // Add data row
    List<dynamic> row = [userId];
    for (int i = 1; i < headers.length; i++) {
      var value = userData[headers[i]];
      
      // Handle special data types
      if (value is Timestamp) {
        value = value.toDate().toString();
      } else if (value is Map || value is List) {
        value = jsonEncode(value);
      }
      
      row.add(value);
    }
    rows.add(row);

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);
    return utf8.encode(csv);
  }

  Future<List<int>> _exportAttendance(CollectionReference subcollection) async {
    try {
      // Get all documents from the subcollection
      final QuerySnapshot querySnapshot = await subcollection.get();
      
      if (querySnapshot.docs.isEmpty) {
        // Return empty CSV with headers
        return utf8.encode('لم يسجل\n');
      }

      final List<String> headers = ['userId', 'date', 'المحتوى'];
      
      // Prepare rows for CSV
      List<List<dynamic>> rows = [];
      
      // Add header row
      rows.add(headers);
      
      // Add data rows
      for (var doc in querySnapshot.docs) {
        final attendance = Attendance.fromFirestore(doc.data() as Map<String, dynamic>);
        List<dynamic> row = [attendance.attendanceId, attendance.userId];
        
        var value = attendance.attendanceLocation;

        if (value == 'other') {
          value = attendance.otherLocation;
        } else {
          value = Attendance.mousqueList[value]!;
        } 
        row.add(value);
        
        rows.add(row);
      }

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(rows);
      return utf8.encode(csv);
    } catch (e) {
      print('Error exporting ddd: $e');
      // Return error CSV
      return utf8.encode('Error exporting data: $e\n');
    }
  }
  Future<List<int>> _exportSubcollection(CollectionReference subcollection) async {
    try {
      // Get all documents from the subcollection
      final QuerySnapshot querySnapshot = await subcollection.get();
      
      if (querySnapshot.docs.isEmpty) {
        // Return empty CSV with headers
        return utf8.encode('لم يسجل\n');
      }

      final List<String> headers = 
        ['userId', 'date', 'صلاة الظهر', 'صلاة العصر', 'صلاة المغرب', 'صلاة العشاء' 
        , 'نصف جزء قرآن', 'أذكار الصباح والمساء', 'تسبيح - 100 مرة', 'إستغفار - 100 مرة',
        "صلاة على النبيّ - 100 مرة", "صلاة على النبيّ - 1000 مرة" , "4 ركعات الضحى", "صلاة التراويح"];
      
      // Prepare rows for CSV
      List<List<dynamic>> rows = [];
      
      // Add header row
      rows.add(headers);
      
      // Add data rows
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final checklist = Checklist.fromFirestore(data);

        List<dynamic> row = [checklist.userId, doc.id];

        // Add values for each header (starting from index 2)
        for (int i = 0; i < checklist.items.length; i++) {
          
          ChecklistItem item = checklist.items.where((item) => item.index == i).first;
          
          
          var value = "";
          
          // Handle special data types
          if (item.itemType == ChecklistItemType.normal) {
            value = jsonEncode(item.isChecked);
          } else if (item.itemType == ChecklistItemType.prayer) {
              switch (item.prayerDoneType) {
                case PrayerDoneType.excused:
                  value = 'عذر شرعي';
                  break;
                case PrayerDoneType.late:
                  value = 'قضاء';
                  break;
                case PrayerDoneType.missed:
                  value = 'لم أصلي';
                  break;
                case PrayerDoneType.ontime:
                  value = 'حاضر';
                  break;
                case PrayerDoneType.ontimeGroup:
                  value = 'جماعة';
                  break;
                default:
                  value = '';
              }
          }
          
          row.add(value);
        }
        
        rows.add(row);
      }

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(rows);
      return utf8.encode(csv);
    } catch (e) {
      print('Error exporting checklist: $e');
      // Return error CSV
      return utf8.encode('Error exporting data: $e\n');
    }
  }
}