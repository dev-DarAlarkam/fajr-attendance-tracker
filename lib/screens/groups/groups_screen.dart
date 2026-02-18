import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/group.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/groups/group_management_screen.dart';
import 'package:attendance_tracker/services/counter_services.dart';
import 'package:attendance_tracker/services/group_services.dart';
import 'package:attendance_tracker/widgets/buttons/back_button.dart' as app_buttons;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupServices _groupServices = GroupServices();
  List<Group> _groups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userProfileProvider = context.read<UserProfileProvider>();
    UserProfile? profile = userProfileProvider.userProfile;
    if (profile == null) {
      await userProfileProvider.fetchUserProfile();
      profile = userProfileProvider.userProfile;
    }

    if (!mounted) return;
    if (profile == null) {
      setState(() {
        _error = 'لم يتم العثور على الملف الشخصي';
        _isLoading = false;
      });
      return;
    }

    try {
      final List<Group> list;
      if (profile.rule == UserProfile.rules[2]) {
        // admin: all groups
        list = await _groupServices.fetchAllGroups();
      } else if (profile.rule == UserProfile.rules[1]) {
        // teacher: only assigned groups
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
        final doc = await _firestore.collection('users').doc(profile.uid).get();
        Teacher? teacher;
        if (doc.exists) {
          teacher = Teacher.fromFirestore(doc.data()!);
          list = await _groupServices.fetchGroupsByIds(teacher.groupIds);
        }
        else {
          list = [];
        }
      } else {
        list = [];
      }

      if (mounted) {
        setState(() {
          _groups = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundPrimaryColor,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: AppConstants.padding,
              margin: AppConstants.margin,
              decoration: AppConstants.boxDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [const app_buttons.BackButton()],
                  ),
                  AppConstants.logo,
                  Text(
                    'إدارة المجموعات',
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _loadGroups,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    )
                  else if (_groups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'لا توجد مجموعات',
                        style: AppConstants.hintStyle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _groups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return _buildGroupTile(group);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile(Group group) {
    return Material(
      color: AppConstants.backgroundPrimaryColor,
      borderRadius: AppConstants.borderRadius,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupManagementScreen(groupId: group.groupId),
            ),
          );
        },
        borderRadius: AppConstants.borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: AppConstants.borderRadius,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الصف: ${group.gradeLevel} • ${group.members.length} طالب',
                      style: AppConstants.hintStyle,
                    ),
                    FutureBuilder(future: CounterServices().fetchGroupCounter(group.groupId), 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("...", style: AppConstants.hintStyle,);
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString(),style: AppConstants.hintStyle,);
                        } else {
                          return Text(snapshot.data.toString() + " طالب سجل", style: AppConstants.hintStyle,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppConstants.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
