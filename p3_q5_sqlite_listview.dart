import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Question 5:
// Write a Flutter app to display all records from an SQLite table using a ListView.

void main() {
  runApp(const P3Q5SqliteListViewApp());
}

class P3Q5SqliteListViewApp extends StatelessWidget {
  const P3Q5SqliteListViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q5 - SQLite Display ListView',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const SqliteListViewScreen(),
    );
  }
}

class SqliteListViewScreen extends StatefulWidget {
  const SqliteListViewScreen({super.key});

  @override
  State<SqliteListViewScreen> createState() => _SqliteListViewScreenState();
}

class _SqliteListViewScreenState extends State<SqliteListViewScreen> {
  Database? _db;
  List<Map<String, dynamic>> _studentsList = [];

  @override
  void initState() {
    super.initState();
    _initAndLoadData();
  }

  Future<void> _initAndLoadData() async {
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

    // Seed dummy records if table is empty
    final count = Sqflite.firstIntValue(await _db!.rawQuery('SELECT COUNT(*) FROM students')) ?? 0;
    if (count == 0) {
      await _db!.insert('students', {'name': 'Rahul Sharma', 'marks': 88.5});
      await _db!.insert('students', {'name': 'Priya Patel', 'marks': 92.0});
      await _db!.insert('students', {'name': 'Amit Verma', 'marks': 79.5});
    }

    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (_db == null) return;
    final List<Map<String, dynamic>> records = await _db!.query('students');
    setState(() {
      _studentsList = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q5: Display SQLite in ListView'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRecords),
        ],
      ),
      body: _studentsList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _studentsList.length,
              itemBuilder: (context, index) {
                final student = _studentsList[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${student['id']}')),
                    title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Marks: ${student['marks']}'),
                  ),
                );
              },
            ),
    );
  }
}
