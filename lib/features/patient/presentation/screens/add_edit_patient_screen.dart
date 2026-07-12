import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/patient_model.dart';
import '../providers/patient_provider.dart';

class AddEditPatientScreen extends StatefulWidget {
  final PatientModel? patient;

  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _historyController;
  late TextEditingController _allergiesController;
  late TextEditingController _imageController;

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  DateTime _selectedDate = DateTime(1995, 1, 1);

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    final isEdit = widget.patient != null;
    final pat = widget.patient;

    _nameController = TextEditingController(text: isEdit ? pat!.fullName : '');
    _emailController = TextEditingController(text: isEdit ? pat!.email : '');
    _phoneController = TextEditingController(text: isEdit ? pat!.phone : '');
    _addressController = TextEditingController(text: isEdit ? pat!.address : '');
    _historyController = TextEditingController(text: isEdit ? pat!.medicalHistory.join(', ') : '');
    _allergiesController = TextEditingController(text: isEdit ? pat!.allergies.join(', ') : '');
    _imageController = TextEditingController(text: isEdit ? pat!.profileImage ?? '' : '');

    if (isEdit) {
      _gender = pat!.gender;
      _bloodGroup = pat.bloodGroup;
      _selectedDate = pat.dob;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _historyController.dispose();
    _allergiesController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _useSampleAvatar() {
    setState(() {
      _imageController.text = 'https://api.dicebear.com/7.x/adventurer/png?seed=${_nameController.text.isNotEmpty ? _nameController.text : "Patient"}';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PatientProvider>(context, listen: false);
      final isEdit = widget.patient != null;

      // Parse comma separated values to clean lists
      final history = _historyController.text.split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final allergies = _allergiesController.text.split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final pat = PatientModel(
        patientId: isEdit ? widget.patient!.patientId : 'pat_${DateTime.now().millisecondsSinceEpoch}',
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _gender,
        dob: _selectedDate,
        bloodGroup: _bloodGroup,
        address: _addressController.text.trim(),
        medicalHistory: history,
        allergies: allergies,
        profileImage: _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
      );

      final success = isEdit
          ? await provider.updatePatient(pat)
          : await provider.addPatient(pat);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? 'Patient profile updated.' : 'Patient profile created.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to save profile.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<PatientProvider>(context);
    final isLoading = provider.isLoading;
    final isEdit = widget.patient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Patient Profile' : 'Add Patient Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name & Email
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'e.g. John Doe',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter patient name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'e.g. john.doe@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone & Address
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: 'e.g. +15551234567',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  hintText: 'Full Home Address...',
                  prefixIcon: Icons.home_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth Picker card
                ListTile(
                  title: Text(
                    'Date of Birth: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),

                // Gender & Blood Group Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.face_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _gender = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _bloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          prefixIcon: Icon(Icons.bloodtype_rounded),
                        ),
                        items: _bloodGroups.map((group) {
                          return DropdownMenuItem(value: group, child: Text(group));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _bloodGroup = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Medical History & Allergies
                CustomTextField(
                  controller: _historyController,
                  label: 'Medical Conditions (comma separated)',
                  hintText: 'e.g. Hypertension, Diabetes, Asthma',
                  prefixIcon: Icons.assignment_rounded,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _allergiesController,
                  label: 'Allergies (comma separated)',
                  hintText: 'e.g. Penicillin, Peanuts, Pollen',
                  prefixIcon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 16),

                // Profile Image URL
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _imageController,
                        label: 'Profile Image URL',
                        hintText: 'https://...',
                        prefixIcon: Icons.image_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _useSampleAvatar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      ),
                      child: const Text('Use Sample'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: isEdit ? 'Update Profile' : 'Register Patient',
                  isLoading: isLoading,
                  onPressed: _onSave,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
