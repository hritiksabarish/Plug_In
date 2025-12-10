import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/role_database_service.dart';
import 'package:app/models/role.dart';
import 'package:app/widgets/glass_container.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  late RoleBasedDatabaseService _roleDatabase;
  List<UserLoginDetails> _users = [];
  UserLoginDetails? _currentUser;
  bool _isLoading = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _roleDatabase = RoleBasedDatabaseService();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await _roleDatabase.getAllUsers();
    final current = await _roleDatabase.getCurrentUser();
    final perms = await _roleDatabase.getCurrentUserPermissions();

    setState(() {
      _users = users;
      _currentUser = current;
      _hasAccess = perms?.hasPermission('manage_roles') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _changeUserRole(UserLoginDetails user, UserRole newRole) async {
    final success = await _roleDatabase.changeUserRole(user.username, newRole.name.toUpperCase());
    if (success) {
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.username} role changed to ${newRole.displayName}')),
      );
    }
  }

  Future<void> _toggleUserActive(UserLoginDetails user) async {
    final success =
        await _roleDatabase.setUserActive(user.username, !user.isActive);
    if (success) {
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.username} is now ${user.isActive ? 'inactive' : 'active'}',
          ),
        ),
      );
    }
  }

  Future<void> _deleteUser(UserLoginDetails user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete ${user.username}?', style: const TextStyle(color: Colors.white70)),
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

    if (confirm ?? false) {
      final success = await _roleDatabase.deleteUser(user.username);
      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.username} deleted')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build the body widget clearly rather than using a nested ternary.
    Widget bodyWidget;

    if (_isLoading) {
      bodyWidget = const Center(child: CircularProgressIndicator(color: Colors.yellow));
    } else if (!_hasAccess) {
      bodyWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg/role_custom.svg',
                width: 64,
                height: 64,
                colorFilter: const ColorFilter.mode(Colors.yellow, BlendMode.srcIn),
              ),
              const SizedBox(height: 12),
              const Text(
                'Access denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text('You do not have permission to manage roles.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    } else {
      bodyWidget = SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100), // Top padding for transparent AppBar
            if (_currentUser != null)
              GlassContainer(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                opacity: 0.05,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current User',
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.yellow),
                    ),
                    const SizedBox(height: 8),
                    Container(width: double.infinity), // Stretch
                    Text('Username: ${_currentUser!.username}', style: const TextStyle(color: Colors.white)),
                    Text('Email: ${_currentUser!.email}', style: const TextStyle(color: Colors.white70)),
                    Text(
                      'Role: ${_currentUser!.role.displayName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'All Users',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_users.length}',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isCurrentUser = _currentUser?.username == user.username;

                return GlassContainer(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.white,
                  opacity: 0.05,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  child: ListTile(
                    title: Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(user.email, style: TextStyle(color: Colors.grey.shade400)),
                        Text(
                          'Role: ${user.role.displayName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        Text(
                          'Status: ${user.isActive ? 'Active' : 'Inactive'}',
                          style: TextStyle(
                            color: user.isActive ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    trailing: isCurrentUser
                        ? const Chip(label: Text('You'), backgroundColor: Colors.yellow, labelStyle: TextStyle(color: Colors.black))
                        : PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            color: const Color(0xFF1E1E1E),
                            onSelected: (value) {
                              if (value == 'toggle_active') {
                                _toggleUserActive(user);
                              } else if (value == 'delete') {
                                _deleteUser(user);
                              } else if (value.startsWith('role_')) {
                                final roleStr = value.replaceFirst('role_', '');
                                final newRole = UserRoleExtension.fromString(roleStr);
                                _changeUserRole(user, newRole);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'toggle_active',
                                child: Text(user.isActive ? 'Deactivate' : 'Activate', style: const TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuDivider(height: 1),
                              const PopupMenuItem(
                                value: 'role_admin',
                                child: Text('Change to Admin', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'role_moderator',
                                child: Text('Change to Moderator', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'role_member',
                                child: Text('Change to Member', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'role_guest',
                                child: Text('Change to Guest', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuDivider(height: 1),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete User',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Role Management', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: GlassContainer(
          child: Container(), // Empty child
          blur: 10,
          opacity: 0.1,
          borderRadius: BorderRadius.zero,
        ),
      ),
      body: Container(
        height: double.infinity, // Ensure full height for gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1E1E1E)],
          ),
        ),
        child: bodyWidget,
      ),
    );
  }
}
