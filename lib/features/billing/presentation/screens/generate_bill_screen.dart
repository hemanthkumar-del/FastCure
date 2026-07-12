import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../doctor/presentation/providers/doctor_provider.dart';
import '../../../patient/presentation/providers/patient_provider.dart';
import '../../data/models/bill_model.dart';
import '../providers/bill_provider.dart';

class GenerateBillScreen extends StatefulWidget {
  const GenerateBillScreen({super.key});

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _docFeeController = TextEditingController(text: '0.0');
  final _medFeeController = TextEditingController(text: '0.0');
  final _labFeeController = TextEditingController(text: '0.0');
  final _appIdController = TextEditingController();

  String? _selectedDoctorId;
  String? _selectedPatientId;
  String _paymentMethod = 'Cash';
  String _status = 'Pending';
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _docFeeController.addListener(_calculateTotal);
    _medFeeController.addListener(_calculateTotal);
    _labFeeController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _docFeeController.dispose();
    _medFeeController.dispose();
    _labFeeController.dispose();
    _appIdController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final doc = double.tryParse(_docFeeController.text) ?? 0.0;
    final med = double.tryParse(_medFeeController.text) ?? 0.0;
    final lab = double.tryParse(_labFeeController.text) ?? 0.0;
    setState(() {
      _total = doc + med + lab;
    });
  }

  void _onDoctorChanged(String? docId, DoctorProvider docProvider) {
    if (docId != null) {
      final doc = docProvider.allDoctors.firstWhere((d) => d.doctorId == docId);
      setState(() {
        _selectedDoctorId = docId;
        _docFeeController.text = doc.consultationFee.toString();
      });
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPatientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a patient file.')),
        );
        return;
      }

      final docProv = Provider.of<DoctorProvider>(context, listen: false);
      final patProv = Provider.of<PatientProvider>(context, listen: false);
      final billProv = Provider.of<BillProvider>(context, listen: false);

      final patient = patProv.allPatients.firstWhere((p) => p.patientId == _selectedPatientId);
      final doctor = _selectedDoctorId != null 
          ? docProv.allDoctors.firstWhere((d) => d.doctorId == _selectedDoctorId)
          : null;

      final bill = BillModel(
        billId: 'bill_${DateTime.now().millisecondsSinceEpoch}',
        patientId: _selectedPatientId!,
        appointmentId: _appIdController.text.trim().isNotEmpty ? _appIdController.text.trim() : 'N/A',
        doctorFee: double.tryParse(_docFeeController.text) ?? 0.0,
        medicineFee: double.tryParse(_medFeeController.text) ?? 0.0,
        labFee: double.tryParse(_labFeeController.text) ?? 0.0,
        total: _total,
        paymentMethod: _paymentMethod,
        status: _status,
        patientName: patient.fullName,
        doctorName: doctor?.fullName ?? 'N/A',
      );

      final success = await billProv.generateBill(bill);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice issued successfully.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(billProv.errorMessage ?? 'Failed to generate invoice.'),
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
    final billProvider = Provider.of<BillProvider>(context);

    final doctors = docProvider.allDoctors;
    final patients = patProvider.allPatients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Invoice'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Patient Dropdown
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

                // Doctor Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  decoration: const InputDecoration(
                    labelText: 'Consulting Doctor (Optional)',
                    prefixIcon: Icon(Icons.people_rounded),
                  ),
                  items: doctors.map((doc) {
                    return DropdownMenuItem(
                      value: doc.doctorId,
                      child: Text('${doc.fullName} (${doc.specialization})'),
                    );
                  }).toList(),
                  onChanged: (value) => _onDoctorChanged(value, docProvider),
                ),
                const SizedBox(height: 16),

                // Appointment ID (Optional)
                CustomTextField(
                  controller: _appIdController,
                  label: 'Appointment Reference ID (Optional)',
                  hintText: 'e.g. app_1209384723984',
                  prefixIcon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 24),

                // Breakdown Inputs Title
                Text(
                  'Itemized Charges (\$)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Breakdown Fee Fields
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _docFeeController,
                        label: 'Doctor Fee',
                        hintText: '0.00',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _medFeeController,
                        label: 'Pharmacy Fee',
                        hintText: '0.00',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _labFeeController,
                        label: 'Lab Fee',
                        hintText: '0.00',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live Total card
                Card(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL AMOUNT DUE:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '\$${_total.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Payment method & initial status Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(labelText: 'Payment Method'),
                        items: const [
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'Card', child: Text('Card')),
                          DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                          DropdownMenuItem(value: 'Insurance', child: Text('Insurance')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _paymentMethod = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _status = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Issue invoice button
                CustomButton(
                  text: 'Generate Invoice',
                  isLoading: billProvider.isLoading,
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
