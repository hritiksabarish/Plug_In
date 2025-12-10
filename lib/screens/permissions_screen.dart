import 'package:flutter/material.dart';
import 'package:app/models/role.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Permissions'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: UserRole.values
              .map((role) => _buildRoleCard(context, role, theme))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    UserRole role,
    ThemeData theme,
  ) {
    final permissions = RolePermissions.getDefaultPermissions(role);

    return Card(
      margin: const EdgeInsets.all(12),
      child: ExpansionTile(
        title: Text(
          role.displayName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
        subtitle: Text('${permissions.permissions.length} permissions'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permissions:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: permissions.permissions
                      .map(
                        (permission) => Chip(
                          label: Text(permission),
                          backgroundColor: Colors.yellow.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
