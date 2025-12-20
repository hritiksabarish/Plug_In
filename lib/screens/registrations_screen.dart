import 'package:flutter/material.dart';
import 'package:app/models/event.dart';

class RegistrationsScreen extends StatelessWidget {
  final Event event;

  const RegistrationsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrations: ${event.title}'),
      ),
      body: event.registrations.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.people_outline, size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('No registrations yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: event.registrations.length,
              itemBuilder: (context, index) {
                final reg = event.registrations[index];
                return ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(reg.name.isNotEmpty ? reg.name[0].toUpperCase() : '?'),
                  ),
                  title: Text(reg.name),
                  subtitle: Text(reg.registerNumber),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.phone, reg.phoneNumber),
                          _buildDetailRow(Icons.email, reg.email),
                          _buildDetailRow(Icons.school, '${reg.studentClass} - ${reg.year}'),
                          _buildDetailRow(Icons.category, reg.department),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
