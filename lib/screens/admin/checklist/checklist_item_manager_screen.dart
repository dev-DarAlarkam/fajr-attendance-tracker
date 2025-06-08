import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/checklist.dart';
import 'package:attendance_tracker/providers/checklist_item_provider.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChecklistItemManagerScreen extends StatelessWidget {
  const ChecklistItemManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    EdgeInsets margin = EdgeInsets.symmetric(vertical: 5, horizontal: 30);

    return Scaffold(
      backgroundColor: AppConstants.backgroundPrimaryColor,
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 400,
              padding: AppConstants.padding,
              margin: margin,
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
                  // Logo Section
                  AppConstants.logo,
                  // Title
                  Text(
                    "إدارة برنامج المحاسبة",
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ItemsCreationDashboard(),
            ItemsViewDashboard(),
          ],
        ),
      )),
    );
  }
}

class ItemsCreationDashboard extends StatefulWidget {
  const ItemsCreationDashboard({super.key});

  @override
  State<ItemsCreationDashboard> createState() => _ItemsCreationDashboardState();
}

class _ItemsCreationDashboardState extends State<ItemsCreationDashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  ChecklistItemType _itemType = ChecklistItemType.normal;
  bool _isPermanent = true;

  final List<bool> _selectedType = [true, false];
  final List<bool> _selectedIsPermanat = [true, false];
  final List<DayOfWeek> _selectedDaysOfWeek = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
          width: 400,
          padding: AppConstants.padding,
          margin: const EdgeInsets.fromLTRB(30, 5, 30, 40),
          decoration: AppConstants.boxDecoration,
          child: Column(
            children: [
              Text(
                "أضف مهمة جديدة",
                style: AppConstants.titleTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ComplexNameTextField(_nameController, "ادخل اسم المهمة"),
              const SizedBox(height: 20),
              _buildTypeToggleSwitch(),
              const SizedBox(height: 20),
              _buildPermenantToggleSwitch(),
              const SizedBox(height: 20),
              _isPermanent
                  ? const SizedBox(height: 20)
                  : _buildDayOfWeekCheckboxList(),
              FirebaseActionButton(onPressed: _submitForm, text: "إضافة مهمة"),
            ],
          )),
    );
  }

  Widget _buildTypeToggleSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('نوع المهمة: ', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 20),
        ToggleButtons(
          isSelected: _selectedType,
          onPressed: (index) {
            setState(() {
              // Reset selection and set the tapped index to true.
              for (int i = 0; i < _selectedType.length; i++) {
                _selectedType[i] = i == index;
              }
              // Save the selected type in _itemType variable.
              _itemType = (index == 0)
                  ? ChecklistItemType.normal
                  : ChecklistItemType.prayer;
            });
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('فعل خير', style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('صلاة مفروضة', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermenantToggleSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('هل تود تكرارها يوميا؟', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 20),
        ToggleButtons(
          isSelected: _selectedIsPermanat,
          onPressed: (index) {
            setState(() {
              // Reset selection and set the tapped index to true.
              for (int i = 0; i < _selectedIsPermanat.length; i++) {
                _selectedIsPermanat[i] = i == index;
              }
              // Save the selected type in _itemType variable.
              _isPermanent = (index == 0) ? true : false;
            });
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('نعم', style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('لا', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayOfWeekCheckboxList() {
    return Column(
      children: [
        Text('اختر الأيام التي تريد تكرار الفعل فيها',
            style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: DayOfWeek.values.map((day) {
            return CheckboxListTile(
              title: Text(Dictionary.daysOfWeek[day.index]),
              value: _selectedDaysOfWeek.contains(day),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _selectedDaysOfWeek.add(day);
                  } else {
                    _selectedDaysOfWeek.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final checklistItem = ChecklistItem(
        id: ChecklistItem.generateItemId(),
        displayName: _nameController.text,
        itemType: _itemType,
        index: context.read<ChecklistItemProvider>().checklistItems.length,
        isPermanent: _isPermanent,
        daysOfWeek: _isPermanent ? null : _selectedDaysOfWeek,
      );

      try {
        await context
            .read<ChecklistItemProvider>()
            .createChecklistItem(checklistItem)
            .then((checklistItem) {
          showSnackBar(context, 'تمت إضافة المهمة بنجاح');
          _nameController.clear();
          _selectedType[0] = true;
          _selectedType[1] = false;
          _selectedIsPermanat[0] = true;
          _selectedIsPermanat[1] = false;
          _selectedDaysOfWeek.clear();
        });
      } catch (e) {
        showSnackBar(context, '$e');
      }
    } else {
      // The error state will be triggered by the validator returning an error message
      if (!_isPermanent && _selectedDaysOfWeek.isEmpty) {
        showSnackBar(context, 'يجب اختيار الأيام التي تريد تكرار المهمة فيها');
      }
    }
  }
}

class ItemsViewDashboard extends StatelessWidget {
  const ItemsViewDashboard({super.key});

  String _itemSubtitle(ChecklistItem item) {
    String subtitle = '';

    if (item.itemType == ChecklistItemType.normal) {
      subtitle += 'فعل خير -';
    } else {
      subtitle += 'صلاة مفروضة -';
    }

    if (item.isPermanent) {
      subtitle += ' يومي';
    } else {
      if (item.daysOfWeek != null) {
        subtitle += ' ${item.daysOfWeek!
                .map((day) => Dictionary.daysOfWeek[day.index])
                .join(', ')}';
      }
    }
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistItemProvider>(
        builder: (context, checklistItemProvider, child) {
      var checklistItems = checklistItemProvider.checklistItems;

      if (checklistItems.isEmpty) {
        return const Text('لا توجد مهام مضافة بعد');
      }

      checklistItems.sort((a, b) => a.index!.compareTo(b.index!));

      return Container(
        width: 400,
        height: 400,
        padding: AppConstants.padding,
        margin: const EdgeInsets.fromLTRB(30, 5, 30, 40),
        decoration: AppConstants.boxDecoration,
        child: Column(
          children: [
            Text(
              "قائمة المهام",
              style: AppConstants.titleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
                  child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = checklistItems.removeAt(oldIndex);
                  checklistItems.insert(newIndex, item);
                  for (int i = 0; i < checklistItems.length; i++) {
                    checklistItems[i].index = i;
                  }
                  checklistItemProvider
                      .createOrpdateChecklistItemsInBulk(checklistItems);
                },
                children: checklistItems.map((entry) {
                  final item = entry;
                  return Card(
                    key: ValueKey(item.id),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Text(item.displayName),
                      subtitle: Text(_itemSubtitle(item)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            await checklistItemProvider
                                .deleteChecklistItem(item.id);
                          } catch (e) {
                            showSnackBar(context, 'Error deleting item: $e');
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              )),
          ],
        ),
      );
    });
  }
}