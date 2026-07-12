import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../doctor/presentation/providers/doctor_provider.dart';
import '../../../medicine/presentation/providers/medicine_provider.dart';
import '../../../patient/presentation/providers/patient_provider.dart';
import '../../data/models/prescription_model.dart';
import '../providers/prescription_provider.dart';

class AddEditPrescriptionScreen extends StatefulWidget {
  const AddEditPrescriptionScreen({super.key});

  @override
  State<AddEditPrescriptionScreen> createState() => _AddEditPrescriptionScreenState();
}

class _AddEditPrescriptionScreenState extends State<AddEditPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _appIdController = TextEditingController();

  String? _selectedDoctorId;
  String? _selectedPatientId;

  // The list of items currently added to this prescription
  final List<_TempPrescriptionItem> _tempItems = [];

  @override
  void dispose() {
    _notesController.dispose();
    _appIdController.dispose();
    super.dispose();
  }

  void _addTempItem() {
    setState(() {
      _tempItems.add(_TempPrescriptionItem());
    });
  }

  void _removeTempItem(int index) {
    setState(() {
      _tempItems.removeAt(index);
    });
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
      if (_tempItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please prescribe at least one medicine.')),
        );
        return;
      }

      final docProv = Provider.of<DoctorProvider>(context, listen: false);
      final patProv = Provider.of<PatientProvider>(context, listen: false);
      final medProv = Provider.of<MedicineProvider>(context, listen: false);
      final presProv = Provider.of<PrescriptionProvider>(context, listen: false);

      final doctor = docProv.allDoctors.firstWhere((d) => d.doctorId == _selectedDoctorId);
      final patient = patProv.allPatients.firstWhere((p) => p.patientId == _selectedPatientId);

      // Build real list items
      final List<PrescriptionItem> medicines = [];
      for (var temp in _tempItems) {
        if (temp.selectedMedicineId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select valid medicines for all items.')),
          );
          return;
        }
        final medicine = medProv.allMedicines.firstWhere((m) => m.medicineId == temp.selectedMedicineId);
        medicines.add(
          PrescriptionItem(
            medicineId: temp.selectedMedicineId!,
            name: medicine.name,
            dosage: temp.dosageController.text.trim(),
            quantity: int.parse(temp.qtyController.text),
          ),
        );
      }

      final prescription = PrescriptionModel(
        prescriptionId: 'pres_${DateTime.now().millisecondsSinceEpoch}',
        doctorId: _selectedDoctorId!,
        patientId: _selectedPatientId!,
        appointmentId: _appIdController.text.trim().isNotEmpty ? _appIdController.text.trim() : 'N/A',
        medicines: medicines,
        notes: _notesController.text.trim(),
        doctorName: doctor.fullName,
        doctorSpecialty: doctor.specialization,
        patientName: patient.fullName,
      );

      final success = await presProv.issuePrescription(prescription, medProv);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription issued successfully.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(presProv.errorMessage ?? 'Failed to issue prescription.'),
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
    final medProvider = Provider.of<MedicineProvider>(context);
    final presProvider = Provider.of<PrescriptionProvider>(context);

    final doctors = docProvider.allDoctors;
    final patients = patProvider.allPatients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Prescription'),
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
                    labelText: 'Consulting Doctor',
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

                // Appointment ID (Optional)
                CustomTextField(
                  controller: _appIdController,
                  label: 'Appointment ID (Optional)',
                  hintText: 'e.g. app_12984723984',
                  prefixIcon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 24),

                // Med list title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Medications List',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _addTempItem,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Item'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Items checklist builder
                ...List.generate(_tempItems.length, (index) {
                  final temp = _tempItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: temp.selectedMedicineId,
                                  decoration: const InputDecoration(labelText: 'Select Medicine'),
                                  items: medProvider.allMedicines.map((m) {
                                    return DropdownMenuItem(
                                      value: m.medicineId,
                                      child: Text('${m.name} (${m.dosage}) - Stock: ${m.stock}'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      temp.selectedMedicineId = val;
                                    });
                                  },
                                  validator: (v) => v == null ? 'Required' : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded),
                                color: theme.colorScheme.error,
                                onPressed: () => _removeTempItem(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: temp.dosageController,
                                  label: 'Dosage Instruction',
                                  hintText: 'e.g. 1-0-1 daily',
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: CustomTextField(
                                  controller: temp.qtyController,
                                  label: 'Qty',
                                  hintText: '10',
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    final num = int.tryParse(v);
                                    if (num == null || num <= 0) return 'Err';
                                    
                                    // Verify stock in memory
                                    if (temp.selectedMedicineId != null) {
                                      final med = medProvider.allMedicines.firstWhere((m) => m.medicineId == temp.selectedMedicineId);
                                      if (med.stock < num) {
                                        return 'Short';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Diagnosis Notes
                CustomTextField(
                  controller: _notesController,
                  label: 'Prescription Advice / Notes',
                  hintText: 'Advice on diet, exercises, rest patterns...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter notes/advice' : null,
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: 'Issue Prescription',
                  isLoading: presProvider.isLoading,
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

class _TempPrescriptionItem {
  String? selectedMedicineId;
  final dosageController = TextEditingController();
  final qtyController = TextEditingController(text: '10');
}
