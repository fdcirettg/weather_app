import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:macos_ui/macos_ui.dart';


class AgregarCiudadesPage extends StatefulWidget {
  final VoidCallback? onCiudadAgregada;
  
  const AgregarCiudadesPage({
    super.key,
    this.onCiudadAgregada, 
  });


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
  Future<List<Map<String, dynamic>>> ciudadesGuardadas = 
      Future<List<Map<String, dynamic>>>.value([]);


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
    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Agregar Ciudades'),
        titleWidth: 150,
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Buscar y agregar nuevas ciudades",
                    style: MacosTheme.of(context).typography.headline,
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de búsqueda con MacosTextField
                  MacosTextField(
                    controller: _cityController,
                    placeholder: 'Ingresa el nombre de la ciudad',
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: MacosIcon(CupertinoIcons.search),
                    ),
                    maxLines: 1,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botón de búsqueda
                  PushButton(
                    controlSize: ControlSize.large,
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
                    child: const Text("Buscar Ciudad"),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Resultados de búsqueda
                  if (ciudadData.isNotEmpty) ...[
                    Text(
                      'Resultados de búsqueda',
                      style: MacosTheme.of(context).typography.headline,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MacosTheme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: ciudadData.length,
                        itemBuilder: (context, index) {
                          final ciudadInfo = ciudadData[index];
                          final isSelected = selectedIndex == index;
                          return MacosListTile(
                            leading: MacosIcon(
                              isSelected 
                                  ? CupertinoIcons.location_fill 
                                  : CupertinoIcons.location,
                              color: isSelected 
                                  ? MacosColors.systemBlueColor 
                                  : null,
                            ),
                            title: Text(
                              ciudadInfo['display_name'],
                              style: TextStyle(
                                fontWeight: isSelected 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              'Lat: ${ciudadInfo['lat']}, Lon: ${ciudadInfo['lon']}',
                            ),
                            onClick: () {
                              setState(() {
                                selectedIndex = index;
                                _cityController.text = ciudadInfo['display_name'];
                                selectedLat = double.parse(ciudadInfo['lat']);
                                selectedLon = double.parse(ciudadInfo['lon']);
                                _mapController.move(
                                  LatLng(selectedLat, selectedLon),
                                  10,
                                );
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Botón agregar ciudad
                  Row(
                    children: [
                      Expanded(
                        child: PushButton(
                          controlSize: ControlSize.large,
                          secondary: selectedIndex == null,
                          onPressed: selectedIndex != null
                              ? () {
                                  _agregarCiudad(
                                    _cityController.text,
                                    selectedLat,
                                    selectedLon,
                                  );
                                }
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              MacosIcon(CupertinoIcons.add_circled),
                              SizedBox(width: 8),
                              Text("Agregar ciudad seleccionada"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Lista de ciudades guardadas
                  Text(
                    'Ciudades guardadas',
                    style: MacosTheme.of(context).typography.headline,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: MacosTheme.of(context).dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: ciudadesGuardadas,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: ProgressCircle(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error ${snapshot.error}'),
                          );
                        }
                        final data = snapshot.data ?? 
                            const <Map<String, dynamic>>[];
                        if (data.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                MacosIcon(
                                  CupertinoIcons.location_slash,
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text('No hay ciudades guardadas.'),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final ciudad = data[index];
                            return MacosListTile(
                              leading: const MacosIcon(
                                CupertinoIcons.location_fill,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ciudad['nombre'].toString()),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lat: ${ciudad["latitud"]} Lon: ${ciudad["longitud"]}',
                                          style: MacosTheme.of(context).typography.caption1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  MacosIconButton(
                                    icon: const MacosIcon(
                                      CupertinoIcons.delete,
                                      color: MacosColors.systemRedColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _eliminarCiudad(
                                        index, 
                                        ciudad['nombre'].toString(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onClick: () {
                                _mapController.move(
                                  LatLng(
                                    ciudad["latitud"],
                                    ciudad["longitud"],
                                  ),
                                  10,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mapa
                  Text(
                    'Mapa',
                    style: MacosTheme.of(context).typography.headline,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 400,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                            urlTemplate: 
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.weather_app',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(selectedLat, selectedLon),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  CupertinoIcons.location_solid,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }


  Future<List> _buscarCiudad(String nombreCiudad) async {
    final url = 
        'https://nominatim.openstreetmap.org/search?q=$nombreCiudad&format=json&addressdetails=1';
    debugPrint('URL de búsqueda: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'WeatherApp/1.0 (Flutter macOS Weather Application; contact: diego.quijada03@gmail.com)',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        debugPrint('Resultados encontrados: ${data.length}');
        if (data.isNotEmpty) {
          return data;
        } else {
          debugPrint('⚠️ No se encontraron resultados para: $nombreCiudad');
        }
      } else {
        debugPrint('⚠️ Error HTTP: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('⚠️ Error al buscar ciudad: $e');
    }
    
    return [];
  }


  void _agregarCiudad(String nombre, double lat, double lon) async {
    debugPrint('=== Iniciando _agregarCiudad ===');
    debugPrint('Nombre: $nombre, Lat: $lat, Lon: $lon');
    
    final prefs = await SharedPreferences.getInstance();
    List<String> listaciudadesGuardadas = 
        prefs.getStringList('ciudades') ?? [];
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
    
    final verificacion = prefs.getStringList('ciudades') ?? [];
    debugPrint('Verificación - Total ciudades guardadas: ${verificacion.length}');
    
    if (!mounted) return;
    
    showMacosAlertDialog(
      context: context,
      builder: (_) => MacosAlertDialog(
        appIcon: const Icon(CupertinoIcons.check_mark_circled, size: 64),
        title: const Text('Ciudad agregada'),
        message: Text('$nombre ha sido agregada exitosamente'),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
    
    setState(() {
      ciudadesGuardadas = _ciudadesGuardadas();
      selectedIndex = null;
      _cityController.clear();
      ciudadData = [];
    });
    
    widget.onCiudadAgregada?.call();
    
    debugPrint('=== Fin _agregarCiudad ===');
  }


  void _eliminarCiudad(int index, String nombreCiudad) async {
    debugPrint('=== Iniciando _eliminarCiudad ===');
    debugPrint('Índice a eliminar: $index, Ciudad: $nombreCiudad');
    
    final prefs = await SharedPreferences.getInstance();
    List<String> listaciudadesGuardadas = 
        prefs.getStringList('ciudades') ?? [];
    debugPrint('Ciudades antes de eliminar: ${listaciudadesGuardadas.length}');
    
    if (index >= 0 && index < listaciudadesGuardadas.length) {
      listaciudadesGuardadas.removeAt(index);
      await prefs.setStringList('ciudades', listaciudadesGuardadas);
      debugPrint('Ciudades después de eliminar: ${listaciudadesGuardadas.length}');
      
      if (!mounted) return;
      
      showMacosAlertDialog(
        context: context,
        builder: (_) => MacosAlertDialog(
          appIcon: const Icon(
            CupertinoIcons.trash, 
            size: 64,
            color: MacosColors.systemRedColor,
          ),
          title: const Text('Ciudad eliminada'),
          message: Text('$nombreCiudad ha sido eliminada exitosamente'),
          primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ),
      );
      
      setState(() {
        ciudadesGuardadas = _ciudadesGuardadas();
      });
      
      widget.onCiudadAgregada?.call();
    }
    
    debugPrint('=== Fin _eliminarCiudad ===');
  }


  Future<List<Map<String, dynamic>>> _ciudadesGuardadas() async {
    debugPrint('=== Cargando ciudades guardadas ===');
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    debugPrint('Total ciudades en SharedPreferences: ${ciudadesString.length}');
    
    if (ciudadesString.isNotEmpty) {
      debugPrint('Primera ciudad: ${ciudadesString.first}');
    }
    
    final resultado = ciudadesString
        .map((ciudadStr) => json.decode(ciudadStr) as Map<String, dynamic>)
        .toList();
    debugPrint('=== Fin carga ciudades ===');
    return resultado;
  }
}
