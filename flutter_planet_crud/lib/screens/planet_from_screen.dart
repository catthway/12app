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
