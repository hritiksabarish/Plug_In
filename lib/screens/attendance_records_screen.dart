import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'attendance_models.dart'; // <-- MUST import the same shared file
import 'attendance_record_detail_screen.dart'; 

class AttendanceRecordsScreen extends StatelessWidget {
  final List<AttendanceRecord> records; // <-- This type is now consistent

  const AttendanceRecordsScreen({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    // ... (The rest of this file's code from the previous answer is correct)
    final sortedRecords = records.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: records.isEmpty
          ? _buildEmptyState(context)
          : _buildRecordsList(context, sortedRecords),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Text('No attendance records found.'),
    );
  }

  Widget _buildRecordsList(
      BuildContext context, List<AttendanceRecord> sortedRecords) {
    return ListView.builder(
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildRecordItem(context, record);
      },
    );
  }

  Widget _buildRecordItem(BuildContext context, AttendanceRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(DateFormat('yyyy-MM-dd – HH:mm').format(record.date)),
        subtitle: Text('Status: ${record.status}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AttendanceRecordDetailScreen(record: record),
            ),
          );
        },
      ),
    );
  }
}