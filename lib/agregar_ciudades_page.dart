import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'app_scaffold.dart';

class AgregarCiudadesPage extends StatefulWidget {
  const AgregarCiudadesPage({super.key});
  @override
  State<AgregarCiudadesPage> createState() => _AgregarCiudadesPageState();
}

class _AgregarCiudadesPageState extends State<AgregarCiudadesPage> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();
  List ciudadData = [];
  double dLat = 29.0948207;
  double dLon = -110.9692202;
  double selectedLat = 29.0948207;
  double selectedLon = -110.9692202;
  int? selectedIndex;
  Future<List<Map<String, dynamic>>> ciudadesGuardadas = Future<List<Map<String, dynamic>>>.value([]);

  @override
  void initState() {
    super.initState();
    ciudadesGuardadas = _ciudadesGuardadas();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
    Widget build(BuildContext context) {
    return AppScaffold(
      title: "Agregar Ciudades",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    final resultados = await _buscarCiudad(ciudad);
                    if (!mounted) return;
                    setState(() {
                      ciudadData = resultados;
                    });
                    debugPrint(ciudadData.toString());
                  }
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                height:200,
                child: ListView.builder(
                  itemCount: ciudadData.length,
                  itemBuilder: (context, index) {
                    final ciudadInfo = ciudadData[index];
                    return ListTile(
                      title: Text(ciudadInfo['display_name']),
                      subtitle: Text('Lat: ${ciudadInfo['lat']}, Lon: ${ciudadInfo['lon']}'),
                      selected: selectedIndex == index,
                      onTap:() {
                        setState(() {
                          selectedIndex = index;
                          _cityController.text = ciudadInfo['display_name'];
                          selectedLat = double.parse(ciudadInfo['lat']);
                          selectedLon = double.parse(ciudadInfo['lon']);
                          _mapController.move(LatLng(selectedLat, selectedLon), 10);
                        });
                      }
                    );
                  },

                ),
              ),
              SizedBox(height: 20),
              //aqui va la lista
              SizedBox(
                height: 200,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: ciudadesGuardadas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error ${snapshot.error}');
                    }
                    final data = snapshot.data ?? const <Map<String, dynamic>> [];
                    if (data.isEmpty) {
                      return const Center(child: Text('No hay ciudades guardadas.'));
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final ciudad = data[index];
                        return ListTile(
                          title: Text(ciudad['nombre'].toString()),
                          subtitle: Text('Lat: ${ciudad["latitud"]} Lon: ${ciudad["longitud"]}'),

                        );
                      },
                    );
                  },
                ), 
                
              ),
              SizedBox(height: 20),
              //aqui va el boton de agegar ciudades
              SizedBox(
                child: ElevatedButton(
                  child: const Text("Agregar ciudad"), 
                  onPressed: () {
                    _agregarCiudad(_cityController.text, selectedLat, selectedLon);
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 300,
                // Agregar mapa con flutter_map con control de zoom.
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(selectedLat, selectedLon),
                    initialZoom: 10,
                    maxZoom: 18,
                    minZoom: 3,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.weather_app',
                      subdomains: ['a', 'b', 'c'],
                    ),
                  ],
                ),

              ),
            ]
          ),
          //Divider(color: Colors.grey.shade300),
      ),
      ),
    );
  }
  Future<List> _buscarCiudad(String nombreCiudad) async {
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
        //final ciudadInfo = data[0];
        return data; 
        /*{
          'nombre': ciudadInfo['display_name'],
          'pais': ciudadInfo['address']['country'],
          'latitud': double.parse(ciudadInfo['lat']),
          'longitud': double.parse(ciudadInfo['lon']),
        };*/
      }
    }
    return [];
    /*{
      'nombre': nombreCiudad,
      'pais': 'País Ejemplo',
      'latitud': 0.0,
      'longitud': 0.0,
    };*/
  }
  void _agregarCiudad(String nombre, double lat, double lon) async {
       debugPrint('=== Iniciando _agregarCiudad ===');
       debugPrint('Nombre: $nombre, Lat: $lat, Lon: $lon');
       
       final prefs = await SharedPreferences.getInstance();
       List<String> listaciudadesGuardadas = prefs.getStringList('ciudades') ?? [];
       debugPrint('Ciudades antes de agregar: ${listaciudadesGuardadas.length}');
       
       String ciudadString = json.encode({
         'nombre': nombre,
         'latitud': lat,
         'longitud': lon,
       });
       debugPrint('Ciudad a agregar (JSON): $ciudadString');
       
       listaciudadesGuardadas.add(ciudadString);
       await prefs.setStringList('ciudades', listaciudadesGuardadas);
       debugPrint('Ciudades después de agregar: ${listaciudadesGuardadas.length}');
       
       // Verificamos que se guardó correctamente
       final verificacion = prefs.getStringList('ciudades') ?? [];
       debugPrint('Verificación - Total ciudades guardadas: ${verificacion.length}');
       
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ciudad agregada: $nombre')),
       );
       // Forzamos la reconstrucción
       setState(() {
          ciudadesGuardadas = _ciudadesGuardadas();
       });
       debugPrint('=== Fin _agregarCiudad ===');
  }
  Future<List<Map<String, dynamic>>> _ciudadesGuardadas() async {
    debugPrint('=== Cargando ciudades guardadas ===');
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    debugPrint('Total ciudades en SharedPreferences: ${ciudadesString.length}');
    
    if (ciudadesString.isNotEmpty) {
      debugPrint('Primera ciudad: ${ciudadesString.first}');
    }
    
    final resultado = ciudadesString.map((ciudadStr) => json.decode(ciudadStr) as Map<String, dynamic>).toList();
    debugPrint('=== Fin carga ciudades ===');
    return resultado;
  }
  
}