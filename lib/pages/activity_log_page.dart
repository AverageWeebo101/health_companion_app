import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({Key? key}) : super(key: key);

  @override
  _ActivityLogPageState createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  List<Map<String, dynamic>> _activityLog = [];
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadActivityLog();
  }

  Future<void> _loadActivityLog() async {
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot logSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('activityLog')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      _activityLog = logSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
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
      body: _activityLog.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
    );
  }
}
