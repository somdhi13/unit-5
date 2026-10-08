import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Question 4:
// Write a Flutter app to insert a new record into the "students" table using SQLite.

void main() {
  runApp(const P3Q4SqliteInsertApp());
}

class P3Q4SqliteInsertApp extends StatelessWidget {
  const P3Q4SqliteInsertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q4 - SQLite Insert Record',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const SqliteInsertScreen(),
    );
  }
}

class SqliteInsertScreen extends StatefulWidget {
  const SqliteInsertScreen({super.key});

  @override
  State<SqliteInsertScreen> createState() => _SqliteInsertScreenState();
}

class _SqliteInsertScreenState extends State<SqliteInsertScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  Database? _db;
  String _message = 'Initializing DB...';

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'students_db.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            marks REAL NOT NULL
          )
        ''');
      },
    );

    setState(() {
      _message = 'SQLite DB connected. Ready to insert record.';
    });
  }

  Future<void> _insertStudent() async {
    final name = _nameController.text.trim();
    final marks = double.tryParse(_marksController.text.trim());

    if (name.isNotEmpty && marks != null && _db != null) {
      final insertedId = await _db!.insert(
        'students',
        {'name': name, 'marks': marks},
      );

      setState(() {
        _message = 'Successfully inserted "$name" with ID: $insertedId';
      });

      _nameController.clear();
      _marksController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Q4: SQLite Insert Student')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Student Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Marks', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Insert into "students" Table'),
              onPressed: _insertStudent,
            ),
            const SizedBox(height: 25),
            Text(_message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
      ),
    );
  }
}
