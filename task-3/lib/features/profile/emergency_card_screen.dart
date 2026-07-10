import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../models/emergency_card.dart';

class EmergencyCardScreen extends ConsumerStatefulWidget {
  const EmergencyCardScreen({super.key});

  @override
  ConsumerState<EmergencyCardScreen> createState() =>
      _EmergencyCardScreenState();
}

class _EmergencyCardScreenState extends ConsumerState<EmergencyCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bloodCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _allergiesCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _bloodCtrl = TextEditingController();
    _contactCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _allergiesCtrl = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    final card = await db.getEmergencyCard();
    if (card != null) {
      _nameCtrl.text = card.name;
      _bloodCtrl.text = card.bloodGroup;
      _contactCtrl.text = card.emergencyContact;
      _notesCtrl.text = card.medicalNotes;
      _allergiesCtrl.text = card.allergies;
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final card = EmergencyCard(
        id: 1,
        name: _nameCtrl.text,
        bloodGroup: _bloodCtrl.text,
        emergencyContact: _contactCtrl.text,
        medicalNotes: _notesCtrl.text,
        allergies: _allergiesCtrl.text,
      );
      await ref.read(databaseProvider).saveEmergencyCard(card);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Emergency Card Saved')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Health Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bloodCtrl,
                decoration: const InputDecoration(labelText: 'Blood Group'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact (Phone)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _allergiesCtrl,
                decoration: const InputDecoration(labelText: 'Allergies'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Medical Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
