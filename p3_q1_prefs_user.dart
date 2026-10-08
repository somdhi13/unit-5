import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Question 1:
// Create a Flutter app that saves a username using Shared Preferences and displays it after the app restarts.

void main() {
  runApp(const P3Q1PrefsUserApp());
}

class P3Q1PrefsUserApp extends StatelessWidget {
  const P3Q1PrefsUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q1 - Save Username Preferences',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PrefsUserScreen(),
    );
  }
}

class PrefsUserScreen extends StatefulWidget {
  const PrefsUserScreen({super.key});

  @override
  State<PrefsUserScreen> createState() => _PrefsUserScreenState();
}

class _PrefsUserScreenState extends State<PrefsUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _savedUsername = 'No username saved';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUsername = prefs.getString('saved_username') ?? 'No username saved';
    });
  }

  Future<void> _saveUsername() async {
    final name = _usernameController.text.trim();
    if (name.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_username', name);
      _usernameController.clear();
      _loadUsername();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username saved to Shared Preferences!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Q1: Save Username via Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Saved Username:\n$_savedUsername',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Username'),
              onPressed: _saveUsername,
            ),
          ],
        ),
      ),
    );
  }
}
