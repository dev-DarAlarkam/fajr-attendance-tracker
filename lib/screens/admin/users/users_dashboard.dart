import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/services/User_services.dart';
import 'package:attendance_tracker/services/group_services.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';


class UsersDashboard extends StatelessWidget {
  
  const UsersDashboard({super.key});
  
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
                // width: 400,
                padding: AppConstants.padding,
                margin: AppConstants.containerMargain,
                decoration: AppConstants.boxDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Back Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BackButton(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "لوحة تحكم المستخدمين",
                      style: AppConstants.titleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              UsersTableBuilder(),
            ],
          ),
        )
      ),
    );
  }
}

class UsersTableBuilder extends StatefulWidget {
  const UsersTableBuilder({super.key});

  @override
  State<UsersTableBuilder> createState() => _UsersTableBuilderState();
}

class _UsersTableBuilderState extends State<UsersTableBuilder> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.padding,
      margin: AppConstants.containerMargain,
      decoration: AppConstants.boxDecoration,
    
      child: StreamBuilder(
        stream: UserProfileServices().getUsersProfileStream(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return buildTable(context, snapshot);
          }
        }
      )
    );
  }

  Widget buildTable(BuildContext context, AsyncSnapshot<List<UserProfile>> snapshot) {

    List<UserProfile> users = snapshot.data!;

    return UsersTable(users: users);
  }
}

class UsersTable extends StatefulWidget {

  final List<UserProfile> users; 
  const UsersTable({required this.users ,super.key});

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  // Variables to track sorting state
  String? _selectedGroup;
  Map<String, String> groups = {};
  TextEditingController controller = TextEditingController();
  int? _sortColumnIndex;
  bool _isAscending = true;
  List<UserProfile> filteredProfiles = [];

  @override
  void initState() {
    super.initState();
    filteredProfiles = widget.users;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      groups = await GroupServices().fetchGroupNames();
    });
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 400,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Group',
                  ),
                  value: _selectedGroup ?? 'All Groups',
                  onChanged: (value) {
                    setState(() {
                      _selectedGroup = value;
                      _filterDataByGroup(value);
                    });
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: 'All Groups',
                      child: Text('كل المجموعات'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'none',
                      child: Text('بدون مجموعة'),
                    ),
                    
                    ...groups.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(width: 30,),
              SizedBox(
                width: 400,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "ابحث عن طالب/ة",
                    hintStyle: AppConstants.hintStyle,
                    enabledBorder: AppConstants.defaultFieldBorder,
                    focusedBorder: AppConstants.focusedFieldBorder,
                  ),
                  onChanged: (value) => _filterDataByName(value),
                ),
              ),
            ],
          ),

          SizedBox(height: 20,),
          DataTable(
            //sorting fields
            sortAscending: _isAscending,
            sortColumnIndex: _sortColumnIndex,
          
            //heading Style
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
            headingRowColor: WidgetStateProperty.all(AppConstants.primaryColor),
            
            //Columns
            columns: [
              DataColumn(label: Text('الاسم'), headingRowAlignment: MainAxisAlignment.center, onSort: _onSortFullName),
              DataColumn(label: Text('الجنس'), headingRowAlignment: MainAxisAlignment.center, onSort: _onSortGender),
              DataColumn(label: Text('المجموعة'), headingRowAlignment: MainAxisAlignment.center, onSort: _onSortGroup),
              DataColumn(label: Text('الدور'), headingRowAlignment: MainAxisAlignment.center, onSort: _onSortRule),
              DataColumn(label: Text('الصف'), headingRowAlignment: MainAxisAlignment.center, numeric: true, onSort: _onSortGrade),
              DataColumn(label: Text(''), headingRowAlignment: MainAxisAlignment.center),
            ],
          
            //Rows
            rows: filteredProfiles.map((user) {
              return DataRow(
                cells: [
                  DataCell(Text(user.fullName)),
                  DataCell(Text(user.gender)),
                  DataCell(Text(groups[user.groupId] ?? user.groupId)),
                  DataCell(Text(user.rule)),
                  DataCell(Text(user.grade)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            _showEditUserDialog(context, user);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.upgrade_sharp),
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
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // Filter FunctionsL
  void _filterDataByGroup(String? selectedGroup) {
    if (selectedGroup == null || selectedGroup == 'All Groups') {
      // No filtering based on group, show all
      setState(() {
        filteredProfiles = widget.users;
      });
    } else {
      // Filter the data to show only users from the selected group
      setState(() {
        filteredProfiles = widget.users
            .where((user) => user.groupId == selectedGroup)
            .toList();
      });
    }
  }

  void _filterDataByName(String fullName){
    if (fullName.isEmpty) {
      setState(() {
        filteredProfiles = widget.users;
      });
    } else {
      setState(() {
        filteredProfiles = widget.users
            .where((user) => user.fullName.contains(fullName))
            .toList();
        
      });
    }
  }
  // ---------------------------------------------------
  // Sorting functions:
  void _onSortFullName(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      widget.users.sort((a, b) {
        final valueA = a.fullName;
        final valueB = b.fullName;

        if (_isAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }
  void _onSortGender(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      widget.users.sort((a, b) {
        final valueA = a.gender;
        final valueB = b.gender;

        if (_isAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }
  void _onSortGroup(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      widget.users.sort((a, b) {
        final valueA = a.groupId;
        final valueB = b.groupId;

        if (_isAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }
  void _onSortRule(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      widget.users.sort((a, b) {
        final valueA = a.rule;
        final valueB = b.rule;

        if (_isAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }
  void _onSortGrade(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      widget.users.sort((a, b) {
        final valueA = a.grade;
        final valueB = b.grade;

        if (_isAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }

}


Future<void> _showEditUserDialog(BuildContext context, UserProfile user) async {

  final TextEditingController _firstNameController = TextEditingController(text: user.firstName);
  final TextEditingController _fatherNameController = TextEditingController(text: user.fatherName);
  final TextEditingController _lastNameController = TextEditingController(text: user.lastName);
  final TextEditingController _birthdayController = TextEditingController(text: user.birthday);
  final TextEditingController _gradeController = TextEditingController(text: user.grade);
  final TextEditingController _genderController = TextEditingController(text: user.gender);


  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('تعديل المستخدم'),

            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Delete user
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
                decoration: InputDecoration(labelText: 'الاسم الأول'),
                controller: _firstNameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'اسم الأب'),
                controller: _fatherNameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'اسم العائلة'),
                controller: _lastNameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'الجنس'),
                controller: _genderController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'الصف'),
                controller: _gradeController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'تاريخ الميلاد'),
                controller: _birthdayController,
              ),
            ],
          ),
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
                final newUser = UserProfile(
                  uid: user.uid, 
                  firstName: _firstNameController.text, 
                  fatherName: _fatherNameController.text, 
                  lastName: _lastNameController.text, 
                  gender: _genderController.text, 
                  birthday: _birthdayController.text, 
                  grade: _gradeController.text, 
                  groupId: user.groupId, 
                  rule: user.rule
                );
                
                await UserProfileServices().updateUserProfile(newUser).then((_) {
                  showSnackBar(context, "User Profile Updated Succefully!");
                  Navigator.of(context).pop();
                });
              
              } catch (e) {
                showSnackBar(context, "Error Updating User Profile: $e");
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showDeleteUserDialog(BuildContext context, UserProfile user) async {
  return showDialog(
    context: context, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("هل تود حذف حساب ${user.fullName}، حقا؟"),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('تأكيد'),
            onPressed: () async {
              try {
                await UserProfileServices().deleteUserProfile(user.uid).then((_) {
                  showSnackBar(context, "User Profile deleted Succefully!");
                  Navigator.of(context).pop();
                });
              
              } catch (e) {
                showSnackBar(context, "Error deleting User Profile: $e");
              }
            },
          ),
        ],
      
      );
    }
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