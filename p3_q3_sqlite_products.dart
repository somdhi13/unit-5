import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Question 3:
// Create an SQLite database with a table named "products" having columns id, name, and price.

void main() {
  runApp(const P3Q3SqliteProductsApp());
}

class Product {
  final int? id;
  final String name;
  final double price;

  Product({this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }
}

class P3Q3SqliteProductsApp extends StatelessWidget {
  const P3Q3SqliteProductsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'P3Q3 - SQLite Products Database',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SqliteProductsScreen(),
    );
  }
}

class SqliteProductsScreen extends StatefulWidget {
  const SqliteProductsScreen({super.key});

  @override
  State<SqliteProductsScreen> createState() => _SqliteProductsScreenState();
}

class _SqliteProductsScreenState extends State<SqliteProductsScreen> {
  Database? _db;
  List<Product> _productsList = [];
  String _dbStatus = 'Initializing SQLite Database...';

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'products_db.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL
          )
        ''');
      },
    );

    setState(() {
      _dbStatus = 'Database initialized & table "products" ready!';
    });

    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    if (_db == null) return;
    final List<Map<String, dynamic>> maps = await _db!.query('products');
    setState(() {
      _productsList = maps.map((m) => Product.fromMap(m)).toList();
    });
  }

  Future<void> _addSampleProduct() async {
    if (_db == null) return;
    final sampleCount = _productsList.length + 1;
    await _db!.insert('products', {
      'name': 'Product #$sampleCount',
      'price': sampleCount * 25.0,
    });
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Q3: SQLite Products Table')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_dbStatus, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Insert Product'),
              onPressed: _addSampleProduct,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _productsList.isEmpty
                  ? const Center(child: Text('No products in SQLite database'))
                  : ListView.builder(
                      itemCount: _productsList.length,
                      itemBuilder: (context, index) {
                        final item = _productsList[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${item.id}')),
                            title: Text(item.name),
                            subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                          ),
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
