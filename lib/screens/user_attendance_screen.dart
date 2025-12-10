import 'package:flutter/material.dart';
import 'package:app/services/role_database_service.dart';
import 'package:app/widgets/glass_container.dart';
import 'package:intl/intl.dart';

class UserAttendanceScreen extends StatefulWidget {
  final String username;

  const UserAttendanceScreen({super.key, required this.username});

  @override
  State<UserAttendanceScreen> createState() => _UserAttendanceScreenState();
}

class _UserAttendanceScreenState extends State<UserAttendanceScreen> {
  final _roleDatabase = RoleBasedDatabaseService();
  List<Map<String, dynamic>> _attendanceHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _roleDatabase.fetchUserAttendance(widget.username);
    if (mounted) {
      setState(() {
        _attendanceHistory = history;
        _isLoading = false;
      });
    }
  }

  double _calculatePercentage() {
    if (_attendanceHistory.isEmpty) return 0.0;
    int present = _attendanceHistory.where((r) => r['status'] == 'PRESENT').length;
    return (present / _attendanceHistory.length) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _calculatePercentage();
    final isPresentable = percentage >= 75.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Attendance History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: GlassContainer(child: Container(), opacity: 0.1, blur: 10),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1E1E1E)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
            : Column(
                children: [
                  const SizedBox(height: 100),
                  // Stats Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      opacity: 0.05,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('${percentage.toStringAsFixed(1)}%', 
                                style: TextStyle(
                                  fontSize: 32, 
                                  fontWeight: FontWeight.bold, 
                                  color: isPresentable ? Colors.greenAccent : Colors.redAccent
                                )
                              ),
                              const Text('Attendance Rate', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Container(height: 50, width: 1, color: Colors.white24),
                          Column(
                            children: [
                              Text('${_attendanceHistory.length}', 
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
                              ),
                              const Text('Total Sessions', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Timeline List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _attendanceHistory.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final record = _attendanceHistory[index];
                        final isPresent = record['status'] == 'PRESENT';
                        final date = DateTime.parse(record['date']);
                        final notes = record['notes'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GlassContainer(
                            borderRadius: BorderRadius.circular(12),
                            color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            opacity: 0.05,
                            child: ListTile(
                              leading: Icon(
                                isPresent ? Icons.check_circle : Icons.cancel,
                                color: isPresent ? Colors.greenAccent : Colors.redAccent,
                                size: 30,
                              ),
                              title: Text(
                                DateFormat('MMM dd, yyyy - hh:mm a').format(date.toLocal()),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: notes != null && notes.isNotEmpty 
                                ? Text(notes, style: const TextStyle(color: Colors.white70))
                                : null,
                              trailing: Text(
                                isPresent ? 'PRESENT' : 'ABSENT',
                                style: TextStyle(
                                  color: isPresent ? Colors.greenAccent : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
