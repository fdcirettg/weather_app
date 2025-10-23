import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_controller.dart';
import 'app_scaffold.dart';

class AgregarCiudadesPage extends StatelessWidget {
 AgregarCiudadesPage({super.key});
  final TextEditingController _cityController = TextEditingController();

  @override
    Widget build(BuildContext context) {
    return AppScaffold(
      title: "Agregar Ciudades",
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: [
              Text(
                "Aquí puedes agregar nuevas ciudades",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Text("Ciudad"),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa el nombre de la ciudad',
                ),
              ),
              // Agregar botón para buscar y agregar ciudad
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Buscar Ciudad"),
                onPressed: () async {
                  final ciudad = _cityController.text;
                  if (ciudad.isNotEmpty) {
                    // Lógica para buscar y agregar la ciudad
                    final ciudadData = _buscarCiudad(ciudad);
                    debugPrint('Ciudad agregada: $ciudadData');
                  }
                },
              ),
            ]
          ),
          Divider(color: Colors.grey.shade300),

        ],
      ),
    );
  }
  Future<Map<String, dynamic>> _buscarCiudad(String nombreCiudad) async {
    // Aquí iría la lógica para buscar la ciudad en una base de datos o API
    // Por ahora, devolvemos un mapa simulado
    // Necesitamos armar el url para  consultar Nominatim con el nombreCiudad
    final url = 'https://nominatim.openstreetmap.org/search?q=$nombreCiudad&format=json&addressdetails=1';
    debugPrint('URL de búsqueda: $url');
    // Hacemos la peticion a Nominatim con el url formado
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final ciudadInfo = data[0];
        return {
          'nombre': ciudadInfo['display_name'],
          'pais': ciudadInfo['address']['country'],
          'latitud': double.parse(ciudadInfo['lat']),
          'longitud': double.parse(ciudadInfo['lon']),
        };
      }
    }
    return {
      'nombre': nombreCiudad,
      'pais': 'País Ejemplo',
      'latitud': 0.0,
      'longitud': 0.0,
    };
  }
  /*
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Ciudades'),
      ),
      body: const Center(
        child: Text('Aquí puedes agregar nuevas ciudades'),
      ),
    );
  }
  */
}
