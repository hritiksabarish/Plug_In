import 'package:flutter/material.dart';
import 'package:app/services/role_database_service.dart';
import 'package:intl/intl.dart';

class MembershipRequestsScreen extends StatefulWidget {
  const MembershipRequestsScreen({super.key});

  @override
  State<MembershipRequestsScreen> createState() => _MembershipRequestsScreenState();
}

class _MembershipRequestsScreenState extends State<MembershipRequestsScreen> {
  final RoleBasedDatabaseService _databaseService = RoleBasedDatabaseService();
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final data = await _databaseService.fetchMembershipRequests();
    if (mounted) {
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    await _databaseService.updateMembershipRequestStatus(id, status);
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Requests'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No pending requests.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    final status = req['status'] ?? 'PENDING';
                    
                    Color statusColor = Colors.orange;
                    if (status == 'APPROVED') statusColor = Colors.green;
                    if (status == 'REJECTED') statusColor = Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(req['name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req['email'] ?? ''),
                            const SizedBox(height: 4),
                            Text('${req['registerNumber'] ?? 'N/A'} | ${req['department'] ?? ''} ${req['year'] ?? ''} ${req['section'] ?? ''}', 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Mobile: ${req['mobileNumber'] ?? 'N/A'}'),
                            const SizedBox(height: 4),
                            Text('Reason: ${req['reason'] ?? ''}', style: const TextStyle(fontStyle: FontStyle.italic)),
                            const SizedBox(height: 4),
                             Text('Date: ${req['requestDate'] != null ? DateFormat.yMMMd().format(DateTime.parse(req['requestDate'])) : 'N/A'}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                            if (status == 'PENDING')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _updateStatus(req['id'], 'APPROVED'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _updateStatus(req['id'], 'REJECTED'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
