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

