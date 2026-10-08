import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Question 2:
// Create a Flutter app with a switch to save and load a "Dark Mode" setting using Shared Preferences.

void main() {
  runApp(const P3Q2PrefsThemeApp());
}

class P3Q2PrefsThemeApp extends StatefulWidget {
  const P3Q2PrefsThemeApp({super.key});

  @override
  State<P3Q2PrefsThemeApp> createState() => _P3Q2PrefsThemeAppState();
}

class _P3Q2PrefsThemeAppState extends State<P3Q2PrefsThemeApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
  }

  Future<void> _loadThemeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode_key') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_key', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q2 - Dark Mode Switch',
      theme: _isDarkMode ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Q2: Dark Mode Setting')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 80,
                  color: _isDarkMode ? Colors.amber : Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  _isDarkMode ? 'Dark Mode ON' : 'Light Mode ON',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Toggle Dark Mode: ', style: TextStyle(fontSize: 18)),
                    Switch(
                      value: _isDarkMode,
                      onChanged: _toggleDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
