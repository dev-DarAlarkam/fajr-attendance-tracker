import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Firebase Functions
import 'package:flutter/services.dart';

class LeaderboardDashboardScreen extends StatefulWidget {

  const LeaderboardDashboardScreen({super.key});

  @override
  State<LeaderboardDashboardScreen> createState() =>
      _LeaderboardDashboardScreenState();
}

class _LeaderboardDashboardScreenState
    extends State<LeaderboardDashboardScreen> {
  DateTimeRange? _selectedDateRange;
  String? _selectedGroup;
  List<String> groups = ['All Groups', 'Group A', 'Group B', 'Group C'];

  // Variable to track filtered leaderboard data
  List<Map<String, dynamic>> filteredData = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Variables to track sorting state
  int? _sortColumnIndex;
  bool _isAscending = true;

  @override
  void initState() {
    _selectedDateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now().add(Duration(days: 1)));
    super.initState();
    // Initially, no data is fetched
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters Section
            _buildFiltersSection(),
            SizedBox(height: 20),
            // Table Section or Error/Loading Message
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator()) // Loading indicator
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!)) // Error message
                      : _buildScrollableLeaderboardTable(),
            ),
          ],
        ),
      ),
    );
  }

  // Filters section with date range picker, group dropdown, and confirm button
  Widget _buildFiltersSection() {
    return Column(
      children: [
        Row(
          children: [
            // Start and End Date Picker
            Expanded(
              child: GestureDetector(
                onTap: _pickDateRange,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedDateRange == null
                        ? 'Select Date Range'
                        : '${DateFormatUtils.formatDate(_selectedDateRange!.start)} - ${DateFormatUtils.formatDate(_selectedDateRange!.end)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            // Group Dropdown
            Expanded(
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
                items: groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        // Confirm Dates Button
        ElevatedButton(
          onPressed: _selectedDateRange == null
              ? null // Disable button if no date range is selected
              : _confirmDates, // Confirm action if dates are selected
          child: Text('Confirm Dates'),
        ),
      ],
    );
  }

  // Confirm date selection and trigger Cloud Function
  Future<void> _confirmDates() async {
    if (_selectedDateRange != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Prepare the data to send to the cloud function
        final String startDate = _selectedDateRange!.start.toString();
        final String endDate = _selectedDateRange!.end.toString();

        // Call your cloud function to get the leaderboard data
        final HttpsCallable callable =
            FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('calculateLeaderboard');
        
        final response = await callable.call(<String,String> {
          "startDate" : startDate.toString(), 
          "endDate" : endDate.toString(), 
          "groupId" : "all".toString()
        });
        
        // Assuming the response contains a list of leaderboard data
        List<dynamic> leaderboard = response.data;

        setState(() {
          filteredData = leaderboard.map((item) {
            return {
              'fullName': item['name'],
              'grade': item['grade'],
              'groupName': item['group'],
              'rank': item['rank'],
              'totalScore': item['totalScore'],
            };
          }).toList();
          _isLoading = false;
        });
      } on FirebaseFunctionsException catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error: ${e.message}";
        });
      } on PlatformException catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error: ${e.message}";
        });
      }
    }
  }

  // Filter the leaderboard data by group
  void _filterDataByGroup(String? selectedGroup) {
    if (selectedGroup == null || selectedGroup == 'All Groups') {
      // No filtering based on group, show all
      setState(() {
        _errorMessage = null;
      });
    } else {
      // Filter the data to show only users from the selected group
      setState(() {
        filteredData = filteredData
            .where((user) => user['groupName'] == selectedGroup)
            .toList();
      });
    }
  }

  // Make the leaderboard table scrollable to prevent overflow
  Widget _buildScrollableLeaderboardTable() {
    if (filteredData.isEmpty) {
      return Center(child: Text("No data available for the selected date range."));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _createColumns(),
          rows: _createRows(),
          sortAscending: _isAscending,
          sortColumnIndex: _sortColumnIndex,
        ),
      ),
    );
  }

  // Create columns for the DataTable
  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        label: Text('الإسم'),
        onSort: (columnIndex, ascending) {
          _onSortColumn(columnIndex, ascending, 'fullName');
        },
      ),
      DataColumn(
        label: Text('الصف'),
        onSort: (columnIndex, ascending) {
          _onSortColumn(columnIndex, ascending, 'grade');
        },
      ),
      DataColumn(
        label: Text('رمز المجموعة'),
        onSort: (columnIndex, ascending) {
          _onSortColumn(columnIndex, ascending, 'groupName');
        },
      ),
      DataColumn(
        label: Text('المرتبة'),
        numeric: true,
        onSort: (columnIndex, ascending) {
          _onSortColumn(columnIndex, ascending, 'rank');
        },
      ),
      DataColumn(
        label: Text('مجموع النقاط'),
        numeric: true,
        onSort: (columnIndex, ascending) {
          _onSortColumn(columnIndex, ascending, 'totalScore');
        },
      ),
    ];
  }

  // Create rows for the DataTable
  List<DataRow> _createRows() {
    return filteredData.map((user) {
      return DataRow(cells: [
        DataCell(Text(user['fullName'])),
        DataCell(Text(user['grade'])),
        DataCell(Text(user['groupName'])),
        DataCell(Text(user['rank'].toString())),
        DataCell(Text(user['totalScore'].toString())),
      ]);
    }).toList();
  }

  // Function to pick date range
  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // Function to handle sorting logic
  void _onSortColumn(int columnIndex, bool ascending, String columnKey) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      // Sort leaderboard data based on the selected column
      filteredData.sort((a, b) {
        final valueA = a[columnKey];
        final valueB = b[columnKey];

        if (_isAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }
}
