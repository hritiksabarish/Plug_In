import 'package:flutter/material.dart';
import 'package:app/services/role_database_service.dart';
import 'package:app/models/role.dart';
import 'dart:convert';
import 'package:app/widgets/glass_container.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app/screens/user_attendance_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _roleDatabase = RoleBasedDatabaseService();
  List<UserLoginDetails> _members = [];
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = true;

  UserLoginDetails? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _roleDatabase.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final members = await _roleDatabase.fetchAllUsers();
      final attendance = await _roleDatabase.fetchAttendanceRecords();
      
      if (mounted) {
        setState(() {
          _members = members;
          _attendanceRecords = attendance;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading members data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateAttendance(String username) {
    if (_attendanceRecords.isEmpty) return 0.0;
    
    int presentCount = 0;
    for (var record in _attendanceRecords) {
      final presentIds = List<String>.from(record['presentUserIds'] ?? []);
      // Assuming username is used as ID for now, or we need to match by ID if available
      // Since UserLoginDetails doesn't have ID, we use username. 
      // Ideally backend should return ID and we use that.
      if (presentIds.contains(username)) {
        presentCount++;
      }
    }
    
    return (presentCount / _attendanceRecords.length) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Members',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.yellow),
            onPressed: _loadData,
          ),
        ],
        flexibleSpace: GlassContainer(
          child: Container(), // Empty child
          blur: 10,
          opacity: 0.1,
          borderRadius: BorderRadius.zero,
        ),
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
            : _members.isEmpty
                ? const Center(child: Text('No members found', style: TextStyle(color: Colors.grey)))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0, left: 16, right: 16, bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total Members',
                                value: _members.length.toString(),
                                icon: Icons.group,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                title: 'Avg. Attendance',
                                value: '${_calculateAverageAttendance().toStringAsFixed(1)}%',
                                icon: Icons.bar_chart,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: _members.length,
                            itemBuilder: (context, index) {
                              final member = _members[index];
                              final attendancePercentage = _calculateAttendance(member.email);

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: MemberCard(
                                      name: member.username,
                                      role: member.role.displayName,
                                      attendance: attendancePercentage,
                                      avatarUrl: member.avatarUrl,
                                      onEdit: (_currentUser?.role == UserRole.admin && member.username != 'admin')
                                          ? () => _showRoleDialog(member)
                                          : null,
                                      onDelete: _canDelete(member)
                                          ? () => _confirmDelete(member)
                                          : null,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserAttendanceScreen(username: member.email),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  bool _canDelete(UserLoginDetails targetUser) {
    if (_currentUser == null) return false;
    if (targetUser.username == 'admin') return false; // Protect root admin
    if (targetUser.username == _currentUser!.username) return false; // Prevent self-delete

    if (_currentUser!.role == UserRole.admin) return true;
    
    if (_currentUser!.role == UserRole.moderator) {
      return targetUser.role == UserRole.member || targetUser.role == UserRole.eventCoordinator;
    }
    
    return false;
  }

  double _calculateAverageAttendance() {
    if (_members.isEmpty) return 0.0;
    double total = 0;
    for (var member in _members) {
      total += _calculateAttendance(member.username);
    }
    return total / _members.length;
  }

  Future<void> _confirmDelete(UserLoginDetails user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${user.username}?\nThis action cannot be undone.', 
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _roleDatabase.deleteUserFromBackend(user.email); // Use email as ID/username
      if (success) {
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.username} removed successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove user')),
          );
        }
      }
    }
  }

  void _showRoleDialog(UserLoginDetails user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Edit Role for ${user.username}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.where((r) => r != UserRole.guest).map((role) {
            return ListTile(
              title: Text(role.displayName, style: const TextStyle(color: Colors.white)),
              leading: Radio<UserRole>(
                value: role,
                groupValue: user.role,
                activeColor: Colors.yellow,
                fillColor: MaterialStateProperty.resolveWith((states) => 
                  states.contains(MaterialState.selected) ? Colors.yellow : Colors.grey),
                onChanged: (UserRole? value) async {
                  if (value != null) {
                    Navigator.pop(context);
                    final success = await _roleDatabase.changeUserRole(user.email, value.value.toUpperCase());
                    if (success) {
                      _loadData(); // Reload list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Role updated successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update role')),
                      );
                    }
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      opacity: 0.05,
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final String name;
  final String role;
  final double attendance;
  final String? avatarUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const MemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.attendance,
    this.avatarUrl,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75.0) {
      return Colors.greenAccent;
    } else if (percentage >= 50.0) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      opacity: 0.05,
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.yellow.withOpacity(0.2),
          backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? (avatarUrl!.startsWith('http') 
                  ? NetworkImage(avatarUrl!) 
                  : MemoryImage(base64Decode(avatarUrl!.contains(',') ? avatarUrl!.split(',').last : avatarUrl!)) as ImageProvider)
              : null,
          child: (avatarUrl == null || avatarUrl!.isEmpty)
              ? const Icon(
                  Icons.person_outline,
                  size: 28,
                  color: Colors.yellow,
                )
              : null,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          name,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          role,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.yellow),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            Text(
              '${attendance.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getAttendanceColor(attendance),
              ),
            ),
          ],
        ),
      ),
    );
  }
}