import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  _ActivityLogPageState createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  List<Map<String, dynamic>> _activityLog = [];
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivityLog();
  }

  Future<void> _loadActivityLog() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _activityLog = [];
          _isLoading = false;
        });
        return;
      }

      QuerySnapshot logSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activityLog')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _activityLog = logSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading activity log: $e");
      setState(() {
        _activityLog = [];
        _isLoading = false;
      });
    }
  }

  void _sortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      if (columnIndex == 0) {
        _activityLog.sort((a, b) {
          Timestamp timeA = a['timestamp'];
          Timestamp timeB = b['timestamp'];
          return ascending ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
        });
      } else if (columnIndex == 1) {
        _activityLog.sort((a, b) {
          String activityA = a['activity'] ?? '';
          String activityB = b['activity'] ?? '';
          return ascending
              ? activityA.compareTo(activityB)
              : activityB.compareTo(activityA);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activityLog.isEmpty
              ? const Center(child: Text('No activity log found.'))
              : Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: screenWidth,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            sortAscending: _sortAscending,
                            sortColumnIndex: _sortColumnIndex,
                            columns: [
                              DataColumn(
                                label: const Text('Date'),
                                onSort: (columnIndex, ascending) =>
                                    _sortTable(columnIndex, ascending),
                              ),
                              DataColumn(
                                label: const Text('Activity Type'),
                                onSort: (columnIndex, ascending) =>
                                    _sortTable(columnIndex, ascending),
                              ),
                              const DataColumn(label: Text('Details')),
                            ],
                            rows: _activityLog.map((log) {
                              Timestamp timestamp = log['timestamp'];
                              String activityType = log['activity'] ?? '';
                              String details = log['details'] ?? '';

                              return DataRow(cells: [
                                DataCell(Text(timestamp.toDate().toString())),
                                DataCell(Text(activityType)),
                                DataCell(Text(details)),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
