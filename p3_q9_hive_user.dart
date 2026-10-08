import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Question 9:
// Create a Flutter app that uses Hive to store and display a user's name and age together.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('user_data_box');
  runApp(const P3Q9HiveUserApp());
}

class P3Q9HiveUserApp extends StatelessWidget {
  const P3Q9HiveUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q9 - Hive Store Name & Age',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HiveUserScreen(),
    );
  }
}

class HiveUserScreen extends StatefulWidget {
  const HiveUserScreen({super.key});

  @override
  State<HiveUserScreen> createState() => _HiveUserScreenState();
}

class _HiveUserScreenState extends State<HiveUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  late Box _userBox;

  String _displayName = 'Not saved';
  String _displayAge = 'Not saved';

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box('user_data_box');
    _loadStoredUserData();
  }

  void _loadStoredUserData() {
    setState(() {
      _displayName = _userBox.get('user_name', defaultValue: 'Not saved');
      _displayAge = _userBox.get('user_age', defaultValue: 'Not saved').toString();
    });
  }

  void _saveUserData() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (name.isNotEmpty && age != null) {
      _userBox.put('user_name', name);
      _userBox.put('user_age', age);

      _nameController.clear();
      _ageController.clear();

      _loadStoredUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name & Age saved together in Hive Box!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Q9: Hive Name & Age Storage')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'User Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'User Age', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Name & Age to Hive'),
              onPressed: _saveUserData,
            ),
            const SizedBox(height: 30),
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Stored User Details in Hive:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text('Name: $_displayName', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Age: $_displayAge years old', style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
