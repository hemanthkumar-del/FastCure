import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../doctor/presentation/providers/doctor_provider.dart';
import '../../../patient/presentation/providers/patient_provider.dart';
import '../../data/models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedDoctorId;
  String? _selectedPatientId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '09:00 AM';

  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a consultant doctor.')),
        );
        return;
      }
      if (_selectedPatientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a patient file.')),
        );
        return;
      }

      final docProv = Provider.of<DoctorProvider>(context, listen: false);
      final patProv = Provider.of<PatientProvider>(context, listen: false);
      final appProv = Provider.of<AppointmentProvider>(context, listen: false);

      final doctor = docProv.allDoctors.firstWhere((d) => d.doctorId == _selectedDoctorId);
      final patient = patProv.allPatients.firstWhere((p) => p.patientId == _selectedPatientId);

      final app = AppointmentModel(
        appointmentId: 'app_${DateTime.now().millisecondsSinceEpoch}',
        doctorId: _selectedDoctorId!,
        patientId: _selectedPatientId!,
        date: _selectedDate,
        time: _selectedTime,
        status: 'Pending',
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim(),
        doctorName: doctor.fullName,
        doctorSpecialty: doctor.specialization,
        patientName: patient.fullName,
      );

      final success = await appProv.bookAppointment(app);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appProv.errorMessage ?? 'Failed to book appointment.'),
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
    
    final docProvider = Provider.of<DoctorProvider>(context);
    final patProvider = Provider.of<PatientProvider>(context);
    final appProvider = Provider.of<AppointmentProvider>(context);
    
    final doctors = docProvider.allDoctors;
    final patients = patProvider.allPatients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Doctor selection dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  decoration: const InputDecoration(
                    labelText: 'Consultant Doctor',
                    prefixIcon: Icon(Icons.people_rounded),
                  ),
                  items: doctors.map((doc) {
                    return DropdownMenuItem(
                      value: doc.doctorId,
                      child: Text('${doc.fullName} (${doc.specialization})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDoctorId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a doctor' : null,
                ),
                const SizedBox(height: 16),

                // Patient selection dropdown
                DropdownButtonFormField<String>(
                  value: _selectedPatientId,
                  decoration: const InputDecoration(
                    labelText: 'Select Patient',
                    prefixIcon: Icon(Icons.assignment_ind_rounded),
                  ),
                  items: patients.map((pat) {
                    return DropdownMenuItem(
                      value: pat.patientId,
                      child: Text(pat.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPatientId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a patient' : null,
                ),
                const SizedBox(height: 16),

                // Date Selector tile
                ListTile(
                  title: Text(
                    'Appointment Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),

                // Select time slot
                Text(
                  'Available Time Slots',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _timeSlots.map((slot) {
                    final isSelected = _selectedTime == slot;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(slot),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTime = slot;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Reason & Notes
                CustomTextField(
                  controller: _reasonController,
                  label: 'Reason for Appointment',
                  hintText: 'e.g. routine wellness checkup, persistent headache...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter appointment reason';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'Symptom Notes (Optional)',
                  hintText: 'Any extra clinical details...',
                  prefixIcon: Icons.note_alt_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Booking Submit Button
                CustomButton(
                  text: 'Confirm Booking Request',
                  isLoading: appProvider.isLoading,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
