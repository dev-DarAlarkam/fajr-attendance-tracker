import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/group.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/services/group_services.dart';
import 'package:attendance_tracker/services/user_services.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/back_button.dart' as app_buttons;
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupManagementScreen extends StatefulWidget {
  final String groupId;

  const GroupManagementScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final GroupServices _groupServices = GroupServices();
  final UserProfileServices _userServices = UserProfileServices();

  Group? _group;
  List<UserProfile> _memberProfiles = [];
  UserProfile? _teacherProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroupAndMembers();
  }

  Future<void> _loadGroupAndMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final group = await _groupServices.fetchGroup(widget.groupId);
      final profiles = <UserProfile>[];
      for (final uid in group.members) {
        try {
          final profile = await _userServices.getUserProfile(uid);
          profiles.add(profile);
        } catch (_) {
          // Skip members whose profile couldn't be loaded
        }
      }
      UserProfile? teacherProfile;
      if (group.teacherId != 'None') {
        try {
          teacherProfile = await _userServices.getUserProfile(group.teacherId);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _group = group;
          _memberProfiles = profiles;
          _teacherProfile = teacherProfile;
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

  Future<void> _showEditGroupDialog() async {
    if (_group == null) return;
    final nameController = TextEditingController(text: _group!.groupName);
    String? selectedGrade = _group!.gradeLevel;
    final gradeOptions = List.generate(12, (i) => (i + 1).toString());
    final isOtherGrade = !gradeOptions.contains(_group!.gradeLevel);
    if (isOtherGrade) selectedGrade = AppConstants.other;
    final otherGradeController = TextEditingController(
      text: isOtherGrade ? _group!.gradeLevel : '',
    );
    bool showOtherGrade = selectedGrade == AppConstants.other;

    if (!mounted) return;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('تعديل المجموعة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NameTextField(nameController, 'اسم المجموعة'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGrade,
                      decoration: InputDecoration(
                        enabledBorder: AppConstants.defaultFieldBorder,
                        focusedBorder: AppConstants.focusedFieldBorder,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                      ),
                      hint: Text('اختر الصف', style: AppConstants.hintStyle),
                      items: List.generate(12, (i) => (i + 1).toString())
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList()
                        ..add(const DropdownMenuItem(
                          value: AppConstants.other,
                          child: Text('آخر'),
                        )),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGrade = value;
                          showOtherGrade = value == AppConstants.other;
                          if (!showOtherGrade) otherGradeController.clear();
                        });
                      },
                    ),
                    if (showOtherGrade) ...[
                      const SizedBox(height: 12),
                      NameTextField(otherGradeController, 'آخر'),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      showSnackBar(ctx, Dictionary.emptyFieldErrorMessage);
                      return;
                    }
                    final grade = selectedGrade == AppConstants.other
                        ? otherGradeController.text.trim()
                        : (selectedGrade ?? '');
                    if (grade.isEmpty && selectedGrade == AppConstants.other) {
                      showSnackBar(ctx, Dictionary.emptyFieldErrorMessage);
                      return;
                    }
                    Navigator.pop(ctx, {
                      'name': nameController.text.trim(),
                      'grade': grade.isEmpty ? (selectedGrade ?? '') : grade,
                    });
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          );
        },
      ),
    );

    nameController.dispose();
    otherGradeController.dispose();

    if (result == null) return;

    final newName = result['name'];
    final newGrade = result['grade'];
    if (newName == null || newGrade == null) return;

    try {
      await _groupServices.updateGroupNameAndGrade(
        _group!.groupId,
        newName,
        newGrade,
      );
      if (mounted) {
        showSnackBar(context, 'تم تحديث المجموعة');
        _loadGroupAndMembers();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'فشل في التحديث: $e');
    }
  }

  Future<void> _showAssignTeacherDialog() async {
    if (_group == null) return;
    List<UserProfile> teachers = [];
    try {
      final all = await _userServices.getUsersProfile();
      teachers = all.where((p) => p.rule == 'teacher').toList();
    } catch (e) {
      if (mounted) showSnackBar(context, 'فشل في تحميل المعلمين: $e');
      return;
    }
    if (!mounted) return;
    if (teachers.isEmpty) {
      showSnackBar(context, 'لا يوجد معلمون مسجلون');
      return;
    }
    final selected = await showDialog<UserProfile>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعيين معلم'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final t = teachers[index];
                return ListTile(
                  title: Text(t.fullName),
                  onTap: () => Navigator.pop(ctx, t),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    try {
      await _groupServices.assignTeachertoGroup(selected.uid, _group!.groupId);
      if (mounted) {
        showSnackBar(context, 'تم تعيين المعلم ${selected.fullName}');
        _loadGroupAndMembers();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'فشل في التعيين: $e');
    }
  }

  Future<void> _removeStudent(UserProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إزالة طالب'),
          content: Text(
            'هل تريد إزالة ${profile.fullName} من المجموعة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'إزالة',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _groupServices.removeUserFromGroup(profile.uid, _group!.groupId);
      if (mounted) {
        showSnackBar(context, 'تم إزالة ${profile.fullName} من المجموعة');
        _loadGroupAndMembers();
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'فشل في الإزالة: $e');
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
                            onPressed: _loadGroupAndMembers,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    )
                  else if (_group != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'تفاصيل المجموعة',
                          style: AppConstants.titleTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          onPressed: _showEditGroupDialog,
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppConstants.primaryColor,
                            size: 28,
                          ),
                          tooltip: 'تعديل اسم المجموعة والصف',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDetailRow('اسم المجموعة', _group!.groupName),
                              _buildDetailRow('الصف', _group!.gradeLevel),
                              _buildDetailRow('رمز المجموعة', _group!.groupId),
                              _buildDetailRow(
                                'المعلم',
                                _teacherProfile?.fullName ?? 'لا يوجد',
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _showAssignTeacherDialog,
                              icon: Icon(
                                Icons.person_add_outlined,
                                color: AppConstants.primaryColor,
                                size: 28,
                              ),
                              tooltip: 'تعيين معلم',
                            ),
                            IconButton(
                              onPressed: () {
                                String message = 'اسم المجموعة: ${_group!.groupName} \nرمز المجموعة: ${_group!.groupId}';
                                Clipboard.setData(ClipboardData(text: message));
                                showSnackBar(context, 'تم النسخ');
                              },
                              icon: Icon(
                                Icons.copy_outlined,
                                color: AppConstants.primaryColor,
                                size: 28,
                              ),
                              tooltip: 'نسخ',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'الطلاب (${_memberProfiles.length})',
                      style: AppConstants.titleTextStyle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    if (_memberProfiles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'لا يوجد طلاب في هذه المجموعة',
                          style: AppConstants.hintStyle,
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _memberProfiles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final profile = _memberProfiles[index];
                          return _buildStudentTile(profile);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: 270,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: Text(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTile(UserProfile profile) {
    return Material(
      color: AppConstants.backgroundPrimaryColor,
      borderRadius: AppConstants.borderRadius,
      child: InkWell(
        onTap: () {},
        borderRadius: AppConstants.borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: AppConstants.borderRadius,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeStudent(profile),
                icon: Icon(
                  Icons.person_remove_outlined,
                  color: Colors.red.shade700,
                  size: 24,
                ),
                tooltip: 'إزالة من المجموعة',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
