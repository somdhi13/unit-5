import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Question 7:
// Write a Flutter app to delete a specific record from an SQLite table based on its id.

void main() {
  runApp(const P3Q7SqliteDeleteApp());
}

class P3Q7SqliteDeleteApp extends StatelessWidget {
  const P3Q7SqliteDeleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q7 - SQLite Delete Record',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const SqliteDeleteScreen(),
    );
  }
}

class SqliteDeleteScreen extends StatefulWidget {
  const SqliteDeleteScreen({super.key});

  @override
  State<SqliteDeleteScreen> createState() => _SqliteDeleteScreenState();
}

class _SqliteDeleteScreenState extends State<SqliteDeleteScreen> {
  Database? _db;
  List<Map<String, dynamic>> _studentsList = [];

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

    _refreshList();
  }

  Future<void> _refreshList() async {
    if (_db == null) return;
    final records = await _db!.query('students');
    setState(() {
      _studentsList = records;
    });
  }

  Future<void> _deleteRecord(int id) async {
    if (_db == null) return;
    await _db!.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted Record ID: $id'), backgroundColor: Colors.red),
      );
    }

    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Q7: Delete Record by ID')),
      body: _studentsList.isEmpty
          ? const Center(child: Text('No records in table.'))
          : ListView.builder(
              itemCount: _studentsList.length,
              itemBuilder: (context, index) {
                final s = _studentsList[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${s['id']}')),
                    title: Text(s['name']),
                    subtitle: Text('Marks: ${s['marks']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRecord(s['id'] as int),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
