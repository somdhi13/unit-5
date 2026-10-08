import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Question 6:
// Write a Flutter app to update a specific record in an SQLite table based on its id.

void main() {
  runApp(const P3Q6SqliteUpdateApp());
}

class P3Q6SqliteUpdateApp extends StatelessWidget {
  const P3Q6SqliteUpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q6 - SQLite Update Record',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SqliteUpdateScreen(),
    );
  }
}

class SqliteUpdateScreen extends StatefulWidget {
  const SqliteUpdateScreen({super.key});

  @override
  State<SqliteUpdateScreen> createState() => _SqliteUpdateScreenState();
}

class _SqliteUpdateScreenState extends State<SqliteUpdateScreen> {
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

  void _showUpdateDialog(Map<String, dynamic> student) {
    final nameController = TextEditingController(text: student['name']);
    final marksController = TextEditingController(text: student['marks'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Record ID: ${student['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: marksController, decoration: const InputDecoration(labelText: 'Marks')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newMarks = double.tryParse(marksController.text.trim());

                if (newName.isNotEmpty && newMarks != null && _db != null) {
                  await _db!.update(
                    'students',
                    {'name': newName, 'marks': newMarks},
                    where: 'id = ?',
                    whereArgs: [student['id']],
                  );
                  Navigator.pop(context);
                  _refreshList();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Q6: Update Record by ID')),
      body: ListView.builder(
        itemCount: _studentsList.length,
        itemBuilder: (context, index) {
          final s = _studentsList[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${s['id']}')),
              title: Text(s['name']),
              subtitle: Text('Marks: ${s['marks']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.purple),
                onPressed: () => _showUpdateDialog(s),
              ),
            ),
          );
        },
      ),
    );
  }
}
