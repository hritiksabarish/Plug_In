
import 'package:flutter/material.dart';
import 'package:app/services/role_database_service.dart';

class RegistrationDialog extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const RegistrationDialog({super.key, required this.eventId, required this.eventTitle});

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _regNumController = TextEditingController();
  final _classController = TextEditingController();
  final _yearController = TextEditingController();
  final _deptController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _regNumController.dispose();
    _classController.dispose();
    _yearController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
        'registerNumber': _regNumController.text,
        'studentClass': _classController.text,
        'year': _yearController.text,
        'department': _deptController.text,
      };

      final success = await RoleBasedDatabaseService().registerForEvent(widget.eventId, data);

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful! You will receive confirmation soon on your email.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Failed. Please try again.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Register for ${widget.eventTitle}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildTextField(_nameController, 'Full Name', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone, inputType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(_emailController, 'Email Address', Icons.email, inputType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildTextField(_regNumController, 'Register Number', Icons.badge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_classController, 'Class', Icons.class_)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_yearController, 'Year', Icons.calendar_today)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_deptController, 'Department', Icons.school),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text('Confirm Registration'),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
