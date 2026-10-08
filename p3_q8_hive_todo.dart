import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Question 8:
// Create a Flutter app that uses Hive to save and display a simple "To-Do" note.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notes_box');
  runApp(const P3Q8HiveTodoApp());
}

class P3Q8HiveTodoApp extends StatelessWidget {
  const P3Q8HiveTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q8 - Hive To-Do Note',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HiveTodoScreen(),
    );
  }
}

class HiveTodoScreen extends StatefulWidget {
  const HiveTodoScreen({super.key});

  @override
  State<HiveTodoScreen> createState() => _HiveTodoScreenState();
}

class _HiveTodoScreenState extends State<HiveTodoScreen> {
  final TextEditingController _noteController = TextEditingController();
  late Box _notesBox;

  @override
  void initState() {
    super.initState();
    _notesBox = Hive.box('notes_box');
  }

  void _addNote() {
    final note = _noteController.text.trim();
    if (note.isNotEmpty) {
      _notesBox.add(note);
      _noteController.clear();
      setState(() {});
    }
  }

  void _deleteNote(int index) {
    _notesBox.deleteAt(index);
    setState(() {});
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Q8: Hive To-Do Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Enter To-Do Note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Save to Hive'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _notesBox.listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('No notes stored in Hive.'));
                  }
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final note = box.getAt(index).toString();
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.note, color: Colors.teal),
                          title: Text(note),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(index),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
