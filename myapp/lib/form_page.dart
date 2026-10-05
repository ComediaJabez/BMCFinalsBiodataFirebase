import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isSaving = false;

  // label -> controller (ito rin ang field names sa Firestore)
  final Map<String, TextEditingController> controllers = {
    'Name': TextEditingController(),
    'Mobile': TextEditingController(),
    'Email Id': TextEditingController(),
    "Father's Name": TextEditingController(),
    "Mother's Name": TextEditingController(),
    'Gender': TextEditingController(),
    'Date of Birth': TextEditingController(),
    'Marital Status': TextEditingController(),
    'Religion': TextEditingController(),
    'Languages Known': TextEditingController(),
    'Qualification': TextEditingController(),
    'Experience': TextEditingController(),
    'Address': TextEditingController(),
    'Place': TextEditingController(),
    'Date': TextEditingController(),
  };

  Future<void> saveData() async {
    if (controllers.values.any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final data = <String, String>{
      for (final e in controllers.entries) e.key: e.value.text.trim(),
    };

    setState(() => isSaving = true);

    try {
      await firestore.collection('biodata').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully')),
      );

      // pagkatapos mag-save, ipakita ang BIO DATA
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BioDataPage(data: data)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bio Data'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final e in controllers.entries) ...[
              TextField(
                controller: e.value,
                maxLines: e.key == 'Experience' || e.key == 'Address' ? 2 : 1,
                keyboardType: e.key == 'Mobile'
                    ? TextInputType.phone
                    : e.key == 'Email Id'
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                decoration: InputDecoration(
                  labelText: e.key,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: isSaving ? null : saveData,
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- BIO DATA PAGE (nasa parehong file na) ----------------

class BioDataPage extends StatelessWidget {
  final Map<String, String> data;

  const BioDataPage({super.key, required this.data});

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          const Text(":"),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 3),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black54)),
              ),
              child: Text(
                value,
                softWrap: true,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    const mainFields = [
      'Name',
      'Mobile',
      'Email Id',
      "Father's Name",
      "Mother's Name",
      'Gender',
      'Date of Birth',
      'Marital Status',
      'Religion',
      'Languages Known',
      'Qualification',
      'Experience',
      'Address',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        title: const Text('Bio Data'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Container(
              width: screenWidth * 0.95,
              constraints: const BoxConstraints(maxWidth: 650),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      "BIO DATA",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  for (final f in mainFields) buildRow(f, data[f] ?? ''),
                  const SizedBox(height: 30),
                  buildRow('Place', data['Place'] ?? ''),
                  buildRow('Date', data['Date'] ?? ''),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

