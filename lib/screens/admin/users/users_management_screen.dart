import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/services/User_services.dart';
import 'package:attendance_tracker/services/group_services.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';

/// Screen that displays all app users with their details,
/// filter by group, sort by full name / gender / group / grade / rule / birthday,
/// and edit user action.
class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundPrimaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: AppConstants.padding,
                margin: AppConstants.containerMargain,
                decoration: AppConstants.boxDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [BackButton()],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "إدارة المستخدمين",
                      style: AppConstants.titleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const _UsersManagementTable(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersManagementTable extends StatefulWidget {
  const _UsersManagementTable();

  @override
  State<_UsersManagementTable> createState() => _UsersManagementTableState();
}

class _UsersManagementTableState extends State<_UsersManagementTable> {
  String? _selectedGroup;
  Map<String, String> _groupNames = {};
  final TextEditingController _searchController = TextEditingController();
  int? _sortColumnIndex;
  bool _isAscending = true;
  List<UserProfile> _displayList = [];

  /// Single stream instance so sort/filter setState does not create new Firestore subscriptions.
  late final Stream<List<UserProfile>> _usersStream =
      UserProfileServices().getUsersProfileStream();

  @override
  void initState() {
    super.initState();
    _loadGroupNames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupNames() async {
    final names = await GroupServices().fetchGroupNames();
    if (mounted) setState(() => _groupNames = names);
  }

  void _applyFilterAndSort(List<UserProfile> users) {
    List<UserProfile> list = List.from(users);

    // Filter by group
    if (_selectedGroup != null && _selectedGroup != 'All Groups') {
      final groupValue = _selectedGroup == 'none' ? 'None' : _selectedGroup!;
      list = list.where((u) => u.groupId == groupValue).toList();
    }

    // Filter by name search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((u) => u.fullName.toLowerCase().contains(query)).toList();
    }

    // Sort
    if (_sortColumnIndex != null) {
      list.sort((a, b) {
        int cmp;
        switch (_sortColumnIndex!) {
          case 0:
            cmp = a.fullName.compareTo(b.fullName);
            break;
          case 1:
            cmp = a.gender.compareTo(b.gender);
            break;
          case 2:
            cmp = a.groupId.compareTo(b.groupId);
            break;
          case 3:
            cmp = a.grade.compareTo(b.grade);
            break;
          case 4:
            cmp = a.rule.compareTo(b.rule);
            break;
          case 5:
            cmp = a.birthday.compareTo(b.birthday);
            break;
          default:
            cmp = 0;
        }
        return _isAscending ? cmp : -cmp;
      });
    }

    _displayList = list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.padding,
      margin: AppConstants.containerMargain,
      decoration: AppConstants.boxDecoration,
      child: StreamBuilder<List<UserProfile>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          _applyFilterAndSort(users);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilters(),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortAscending: _isAscending,
                  sortColumnIndex: _sortColumnIndex,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  headingRowColor: WidgetStateProperty.all(AppConstants.primaryColor),
                  columns: [
                    DataColumn(
                      label: const Text('الاسم الكامل'),
                      onSort: (idx, asc) => _onSort(idx, asc),
                    ),
                    DataColumn(
                      label: const Text('الجنس'),
                      onSort: (idx, asc) => _onSort(idx, asc),
                    ),
                    DataColumn(
                      label: const Text('المجموعة'),
                      onSort: (idx, asc) => _onSort(idx, asc),
                    ),
                    DataColumn(
                      label: const Text('الصف'),
                      onSort: (idx, asc) => _onSort(idx, asc),
                    ),
                    DataColumn(
                      label: const Text('الدور'),
                      onSort: (idx, asc) => _onSort(idx, asc),
                    ),
                    DataColumn(
                      label: const Text('تاريخ الميلاد'),
                      onSort: (idx, asc) => _onSort(idx, asc),
                    ),
                    const DataColumn(label: Text('إجراءات')),
                  ],
                  rows: _displayList.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(Text(user.fullName)),
                        DataCell(Text(user.gender)),
                        DataCell(Text(_groupNames[user.groupId] ?? user.groupId)),
                        DataCell(Text(user.grade)),
                        DataCell(Text(user.rule)),
                        DataCell(Text(user.birthday)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditUserDialog(context, user);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.upgrade_sharp),
                                onPressed: () {
                                  _showChangeRuleDialog(context, user);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 280,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'المجموعة',
            ),
            value: _selectedGroup ?? 'All Groups',
            onChanged: (value) {
              setState(() {
                _selectedGroup = value;
              });
            },
            items: [
              const DropdownMenuItem(value: 'All Groups', child: Text('كل المجموعات')),
              const DropdownMenuItem(value: 'none', child: Text('بدون مجموعة')),
              ..._groupNames.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 280,
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'ابحث بالاسم',
              hintStyle: AppConstants.hintStyle,
              enabledBorder: AppConstants.defaultFieldBorder,
              focusedBorder: AppConstants.focusedFieldBorder,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }
}

Future<void> _showEditUserDialog(BuildContext context, UserProfile user) async {
  final firstNameController = TextEditingController(text: user.firstName);
  final fatherNameController = TextEditingController(text: user.fatherName);
  final lastNameController = TextEditingController(text: user.lastName);
  final birthdayController = TextEditingController(text: user.birthday);
  final gradeController = TextEditingController(text: user.grade);
  final genderController = TextEditingController(text: user.gender);

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text('تعديل المستخدم'),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteUserDialog(context, user);
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'الاسم الأول'),
                controller: firstNameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'اسم الأب'),
                controller: fatherNameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'اسم العائلة'),
                controller: lastNameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'الجنس'),
                controller: genderController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'الصف'),
                controller: gradeController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'تاريخ الميلاد'),
                controller: birthdayController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updated = UserProfile(
                  uid: user.uid,
                  firstName: firstNameController.text,
                  fatherName: fatherNameController.text,
                  lastName: lastNameController.text,
                  gender: genderController.text,
                  birthday: birthdayController.text,
                  grade: gradeController.text,
                  groupId: user.groupId,
                  rule: user.rule,
                );
                await UserProfileServices().updateUserProfile(updated);
                if (context.mounted) {
                  showSnackBar(context, 'تم تحديث الملف الشخصي بنجاح');
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  showSnackBar(context, 'خطأ في التحديث: $e');
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      );
    },
  );
}

Future<void> _showDeleteUserDialog(BuildContext context, UserProfile user) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('هل تود حذف حساب ${user.fullName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await UserProfileServices().deleteUserProfile(user.uid);
                if (context.mounted) {
                  showSnackBar(context, 'تم حذف الملف الشخصي بنجاح');
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  showSnackBar(context, 'خطأ في الحذف: $e');
                }
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      );
    },
  );
}

Future<void> _showChangeRuleDialog(BuildContext context, UserProfile user) async {

  String _currentRule = user.rule;
  
  return showDialog(
    context: context, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("تغيير الدور الخاص بـ ${user.fullName}"),
        content:  DropdownButtonFormField<String>(
            value: _currentRule,
            hint: Text(_currentRule, style: AppConstants.hintStyle,),
            items: UserProfile.rules
                .map((rule) => DropdownMenuItem(value: rule, child: Text(rule)))
                .toList(),
            onChanged: (value) => _currentRule = value!,
          ),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('حفظ'),
            onPressed: () async {
              try {
                await UserProfileServices().changeUserRule(user.uid, _currentRule).then((_) {
                  showSnackBar(context, "User's Rule edited Succefully!");
                  Navigator.of(context).pop();
                });
              
              } catch (e) {
                showSnackBar(context, "Error editing User's rule: $e");
              }
            },
          ),
        ],
      );
    }
  );
}