import 'package:flutter/material.dart';
import 'package:app/models/announcement.dart';
import 'package:app/models/event.dart';
import 'package:app/screens/announcements_screen.dart' as announcements_data;
import 'package:app/screens/events_screen.dart' as events_data;
import 'package:intl/intl.dart';
import 'package:app/services/role_database_service.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  final RoleBasedDatabaseService _databaseService = RoleBasedDatabaseService();
  List<Event> _events = [];
  bool _isLoadingEvents = true;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController(); 
  final _sectionController = TextEditingController();
  final _registerNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPublicEvents();
  }

  Future<void> _loadPublicEvents() async {
    final data = await _databaseService.fetchEvents(publicOnly: true);
    if (mounted) {
      setState(() {
        _events = data.map((json) => Event.fromJson(json)).toList();
        _isLoadingEvents = false;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _registerNumberController.text.isEmpty ||
        _mobileNumberController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields')));
       return;
    }

    setState(() => _isSubmitting = true);

    final success = await _databaseService.submitMembershipRequest({
      'name': _nameController.text,
      'email': _emailController.text,
      'department': _departmentController.text,
      'year': _yearController.text,
      'section': _sectionController.text,
      'registerNumber': _registerNumberController.text,
      'mobileNumber': _mobileNumberController.text,
      'reason': _reasonController.text,
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _nameController.clear();
        _emailController.clear();
        _departmentController.clear();
        _yearController.clear();
        _sectionController.clear();
        _registerNumberController.clear();
        _mobileNumberController.clear();
        _reasonController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application sent successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send application. Try again.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Slug N Plug'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // About Us Section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Us',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Slug N Plug is a club for students interested in technology and software development. We organize events, workshops, and projects to help our members learn and grow.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming Events Section
          Text(
            'Upcoming Events',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _isLoadingEvents
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? const Center(child: Text('No upcoming public events.'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          return EventCard(event: _events[index]);
                        },
                      ),
          ),
          const SizedBox(height: 32),
          
          // Become a Member Form
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Become a Member', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Join our community to access exclusive events and projects.'),
                  const SizedBox(height: 16),
                  
                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register Number & Mobile
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _registerNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Register Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _mobileNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Department, Year, Section
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.school),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _sectionController,
                          decoration: const InputDecoration(
                            labelText: 'Sec',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Reason
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Why do you want to join?',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitApplication,
                      icon: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Icon(Icons.send),
                      label: Text(_isSubmitting ? 'Sending...' : 'Submit Application'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Already a member? Login here'),
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 250,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(right: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMd().format(event.date),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().format(announcement.date),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(announcement.content, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}