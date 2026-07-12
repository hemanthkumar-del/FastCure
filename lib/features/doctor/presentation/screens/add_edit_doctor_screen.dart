import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/doctor_model.dart';
import '../providers/doctor_provider.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final DoctorModel? doctor;

  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specController;
  late TextEditingController _qualController;
  late TextEditingController _expController;
  late TextEditingController _feeController;
  late TextEditingController _hospitalController;
  late TextEditingController _deptController;
  late TextEditingController _bioController;
  late TextEditingController _imageController;

  String _status = 'Active';
  final List<String> _daysList = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  final List<String> _selectedDays = [];

  final List<String> _slotsList = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'
  ];
  final List<String> _selectedSlots = [];

  @override
  void initState() {
    super.initState();
    final isEdit = widget.doctor != null;
    final doc = widget.doctor;

    _nameController = TextEditingController(text: isEdit ? doc!.fullName : '');
    _emailController = TextEditingController(text: isEdit ? doc!.email : '');
    _phoneController = TextEditingController(text: isEdit ? doc!.phoneNumber : '');
    _specController = TextEditingController(text: isEdit ? doc!.specialization : '');
    _qualController = TextEditingController(text: isEdit ? doc!.qualification : '');
    _expController = TextEditingController(text: isEdit ? doc!.experience.toString() : '');
    _feeController = TextEditingController(text: isEdit ? doc!.consultationFee.toStringAsFixed(0) : '');
    _hospitalController = TextEditingController(text: isEdit ? doc!.hospitalName : '');
    _deptController = TextEditingController(text: isEdit ? doc!.department : '');
    _bioController = TextEditingController(text: isEdit ? doc!.bio : '');
    _imageController = TextEditingController(text: isEdit ? doc!.profileImage ?? '' : '');
    
    if (isEdit) {
      _status = doc!.status;
      _selectedDays.addAll(doc.availableDays);
      _selectedSlots.addAll(doc.availableTimeSlots);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specController.dispose();
    _qualController.dispose();
    _expController.dispose();
    _feeController.dispose();
    _hospitalController.dispose();
    _deptController.dispose();
    _bioController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _useSampleAvatar() {
    setState(() {
      _imageController.text = 'https://api.dicebear.com/7.x/adventurer/png?seed=${_nameController.text.isNotEmpty ? _nameController.text : "Doctor"}';
    });
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one available work day.')),
        );
        return;
      }
      if (_selectedSlots.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one available time slot.')),
        );
        return;
      }

      final provider = Provider.of<DoctorProvider>(context, listen: false);
      final isEdit = widget.doctor != null;

      final doc = DoctorModel(
        doctorId: isEdit ? widget.doctor!.doctorId : 'doc_${DateTime.now().millisecondsSinceEpoch}',
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        specialization: _specController.text.trim(),
        qualification: _qualController.text.trim(),
        experience: int.parse(_expController.text),
        consultationFee: double.parse(_feeController.text),
        hospitalName: _hospitalController.text.trim(),
        department: _deptController.text.trim(),
        bio: _bioController.text.trim(),
        profileImage: _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
        availableDays: _selectedDays,
        availableTimeSlots: _selectedSlots,
        status: _status,
      );

      final success = isEdit
          ? await provider.updateDoctor(doc)
          : await provider.addDoctor(doc);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? 'Doctor updated.' : 'Doctor created.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to save record.'),
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
    final provider = Provider.of<DoctorProvider>(context);
    final isLoading = provider.isLoading;
    final isEdit = widget.doctor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Doctor' : 'Add Doctor'),
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
                  hintText: 'e.g. Dr. Jane Doe',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter doctor name';
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
                  hintText: 'e.g. jane.doe@fastcure.app',
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

                // Phone & Specialization
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
                  controller: _specController,
                  label: 'Specialization',
                  hintText: 'e.g. Cardiologist, Dermatologist',
                  prefixIcon: Icons.local_hospital_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter specialization';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Qualification & Hospital
                CustomTextField(
                  controller: _qualController,
                  label: 'Qualification',
                  hintText: 'e.g. MD, MBBS, FRCS',
                  prefixIcon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _hospitalController,
                  label: 'Hospital Name',
                  hintText: 'e.g. General Health Hospital',
                  prefixIcon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),

                // Department & Bio
                CustomTextField(
                  controller: _deptController,
                  label: 'Department',
                  hintText: 'e.g. Cardiology, Pediatrics',
                  prefixIcon: Icons.domain_rounded,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _bioController,
                  label: 'Biography',
                  hintText: 'Describe experience and clinical focus...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Experience & Consultation Fee
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _expController,
                        label: 'Experience (Years)',
                        hintText: 'e.g. 8',
                        prefixIcon: Icons.history_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final num = int.tryParse(value);
                          if (num == null || num < 0) {
                            return 'Must be positive';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _feeController,
                        label: 'Fee (\$)',
                        hintText: 'e.g. 100',
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num < 0) {
                            return 'Must be positive';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Available Days Checkbox Grid
                Text(
                  'Select Available Days',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _daysList.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(day),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Available Time Slots Checkbox Grid
                Text(
                  'Select Available Time Slots',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _slotsList.map((slot) {
                    final isSelected = _selectedSlots.contains(slot);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(slot),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSlots.add(slot);
                          } else {
                            _selectedSlots.remove(slot);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: isEdit ? 'Update Doctor Details' : 'Register Doctor',
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
