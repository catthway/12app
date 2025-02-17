/// main.dart
import 'package:flutter/material.dart';
import 'screens/planet_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Planetas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PlanetListScreen(),
    );
  }
}

/// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('planets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE planets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        distance REAL NOT NULL,
        size INTEGER NOT NULL,
        nickname TEXT
      )
    ''');
  }

  Future<int> insertPlanet(Map<String, dynamic> planet) async {
    final db = await instance.database;
    return await db.insert('planets', planet);
  }

  Future<List<Map<String, dynamic>>> getPlanets() async {
    final db = await instance.database;
    return await db.query('planets');
  }

  Future<int> updatePlanet(Map<String, dynamic> planet) async {
    final db = await instance.database;
    return await db.update('planets', planet, where: 'id = ?', whereArgs: [planet['id']]);
  }

  Future<int> deletePlanet(int id) async {
    final db = await instance.database;
    return await db.delete('planets', where: 'id = ?', whereArgs: [id]);
  }
}

/// planet_list_screen.dart
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'planet_form_screen.dart';

class PlanetListScreen extends StatefulWidget {
  @override
  _PlanetListScreenState createState() => _PlanetListScreenState();
}

class _PlanetListScreenState extends State<PlanetListScreen> {
  List<Map<String, dynamic>> planets = [];

  @override
  void initState() {
    super.initState();
    _loadPlanets();
  }

  void _loadPlanets() async {
    final data = await DatabaseHelper.instance.getPlanets();
    setState(() {
      planets = data;
    });
  }

  void _deletePlanet(int id) async {
    await DatabaseHelper.instance.deletePlanet(id);
    _loadPlanets();
  }

  void _navigateToForm({Map<String, dynamic>? planet}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlanetFormScreen(planet: planet)),
    );
    _loadPlanets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Planetas')),
      body: ListView.builder(
        itemCount: planets.length,
        itemBuilder: (context, index) {
          final planet = planets[index];
          return ListTile(
            title: Text(planet['name']),
            subtitle: Text(planet['nickname'] ?? 'Sem apelido'),
            onTap: () => _navigateToForm(planet: planet),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePlanet(planet['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToForm(),
      ),
    );
  }
}

/// planet_form_screen.dart
import 'package:flutter/material.dart';
import '../database_helper.dart';

class PlanetFormScreen extends StatefulWidget {
  final Map<String, dynamic>? planet;

  PlanetFormScreen({this.planet});

  @override
  _PlanetFormScreenState createState() => _PlanetFormScreenState();
}

class _PlanetFormScreenState extends State<PlanetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String nickname = '';
  double distance = 0;
  int size = 0;

  @override
  void initState() {
    super.initState();
    if (widget.planet != null) {
      name = widget.planet!['name'];
      nickname = widget.planet!['nickname'] ?? '';
      distance = widget.planet!['distance'];
      size = widget.planet!['size'];
    }
  }

  void _savePlanet() async {
    if (_formKey.currentState!.validate()) {
      final planet = {
        'name': name,
        'nickname': nickname,
        'distance': distance,
        'size': size,
      };
      if (widget.planet == null) {
        await DatabaseHelper.instance.insertPlanet(planet);
      } else {
        planet['id'] = widget.planet!['id'];
        await DatabaseHelper.instance.updatePlanet(planet);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.planet == null ? 'Adicionar Planeta' : 'Editar Planeta')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (value) => name = value,
                validator: (value) => value!.isEmpty ? 'Preencha este campo' : null,
              ),
              TextFormField(
                initialValue: nickname,
                decoration: InputDecoration(labelText: 'Apelido'),
                onChanged: (value) => nickname = value,
              ),
              TextFormField(
                initialValue: distance.toString(),
                decoration: InputDecoration(labelText: 'Distância'),
                keyboardType: TextInputType.number,
                onChanged: (value) => distance = double.tryParse(value) ?? 0,
              ),
              TextFormField(
                initialValue: size.toString(),
                decoration: InputDecoration(labelText: 'Tamanho'),
                keyboardType: TextInputType.number,
                onChanged: (value) => size = int.tryParse(value) ?? 0,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePlanet,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
