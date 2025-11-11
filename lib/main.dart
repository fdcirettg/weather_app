import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app_scaffold.dart';
import 'theme_provider.dart';
import 'agregar_ciudades_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'clima_carousel_view.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final GoRouter router = GoRouter(routes:  [
      GoRoute(path: '/', builder: (context, state) => const MyHomePage(title:'Inicio')),
      GoRoute(path: '/agregar_ciudades', builder: (context, state) => AgregarCiudadesPage()),
      
    ]);
    return MaterialApp.router( title: 'Weather App',
      routerConfig: router,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode, 
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Map<String, dynamic>>> ciudadesGuardadas = Future<List<Map<String, dynamic>>>.value([]);
// Cargamos url, user  y pass desde el archivo .env
  static String get apiTokenUrl => dotenv.env['meteomatics_api_url'] ?? 'https://login.meteomatics.com/api/v1/token';
  static String get username => dotenv.env['meteomatics_user'] ?? '';
  static String get password => dotenv.env['meteomatics_pwd'] ?? '';
  Map<String, dynamic> city = {};
  String apiToken = '';
  int? selectedIndex;

@override
  void initState() {
    super.initState();
    debugPrint('API URL: $apiTokenUrl');
    debugPrint('Username: $username');
    // imprime la contraseña de forma segura sin mostrarla completa
    debugPrint('Password: ${'*' * password.length}');
    // aquí vamos a llamar a la función para obtener el token
    obtenToken();
    // acá vamos a cargar las ciudades guardadas y usar la primera para actualizar el clima
    //_cargarYActualizarPrimeraCiudad();
    ciudadesGuardadas = _ciudadesGuardadas();
  }
  
  Future<void> _cargarYActualizarPrimeraCiudad() async {
    final ciudades = await _ciudadesGuardadas();
    setState(() {
      ciudadesGuardadas = Future.value(ciudades);
    });
    
    if (ciudades.isNotEmpty) {
      city = ciudades[0];
      debugPrint('Primera ciudad cargada: ${city['nombre']}');
      // Esperamos un poco para asegurarnos de que el token esté disponible
      await Future.delayed(const Duration(seconds: 1));
      await _actualizaClima(city);
    } else {
      debugPrint('No hay ciudades guardadas para actualizar el clima');
    }
  }

Future<List<Map<String, dynamic>>> _ciudadesGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    return ciudadesString.map((ciudad) => json.decode(ciudad) as Map<String, dynamic>).toList();
  }

  void obtenToken() async {
    // Lógica para obtener el token de la API usando apiTokenUrl, username y password
    // y luego asignarlo a la variable apiToken
    // Si ya tenemos el token, no hacemos nada
    if (apiToken.isNotEmpty) return;
    // Aquí iría la lógica real para obtener el token
    String url = apiTokenUrl;
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        apiToken = data['access_token'];
      });
      debugPrint('Token obtenido: $apiToken');
    } else {
      debugPrint('Error al obtener el token: ${response.statusCode}');
    }
  }

  Future<void> _actualizaClima(Map<String, dynamic> ciudad) async {
    // Lógica para actualizar el clima de la ciudad usando el apiToken
    // Aquí iría la lógica real para obtener los datos del clima
    debugPrint('Actualizando clima para ${ciudad['nombre']} con token $apiToken');
    if (apiToken.isEmpty) {
      debugPrint('No se puede actualizar el clima sin un token válido.');
      return;
    }
    bool actualizar = false;
    String nombreCiudad = ciudad['nombre'] ?? 'Desconocida';
    double latitud = ciudad['latitud'] ?? 0.0;
    double longitud = ciudad['longitud'] ?? 0.0;
    debugPrint('Ciudad: $nombreCiudad, Latitud: $latitud, Longitud: $longitud');
    String ultimaActualizacion = '';
    if (ciudad['ultima_actualizacion'] == null) {
      actualizar = true;
    } else {
      ultimaActualizacion = ciudad['ultima_actualizacion'];
      DateTime ultimaActualizacionDT = DateTime.parse(ultimaActualizacion);
      DateTime ahoraZ = DateTime.now().toUtc();
      Duration diferencia = ahoraZ.difference(ultimaActualizacionDT);
      if (diferencia.inMinutes >= 60) {
        actualizar = true;  
      }
    }
    String hora_actualZ = DateTime.now().toUtc().toIso8601String();
    // Si es necesario actualizar, hacemos la llamada a la API
    if (actualizar) {
      String url = 'https://api.meteomatics.com/$hora_actualZ/t_2m:C,wind_speed_10m:ms,weather_symbol_1h:idx/$latitud,$longitud/json?access_token=$apiToken';
      debugPrint('URL de la API: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final climaData = json.decode(response.body);
        final data = climaData['data']; 
        // Obtenemos los datos del clima
        final t2m = data[0]['coordinates'][0]['dates'][0]['value'];
        final windSpeed = data[1]['coordinates'][0]['dates'][0]['value'];
        final weatherSymbol = data[2]['coordinates'][0]['dates'][0]['value'];
        ultimaActualizacion = data[0]['coordinates'][0]['dates'][0]['date'];
        debugPrint('Clima para $nombreCiudad - Temperatura: $t2m, Viento: $windSpeed, Símbolo: $weatherSymbol');
        // Aquí actualizaríamos la ciudad con los nuevos datos
        ciudad['temperatura'] = t2m;
        ciudad['velocidad_viento'] = windSpeed;
        ciudad['simbolo_clima'] = weatherSymbol;
        ciudad['ultima_actualizacion'] = ultimaActualizacion;
        
        // Guardamos los cambios en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final ciudadesActualizadas = await ciudadesGuardadas;
        final ciudadesString = ciudadesActualizadas.map((c) {
          if (c['nombre'] == ciudad['nombre']) {
            return json.encode(ciudad);
          }
          return json.encode(c);
        }).toList();
        await prefs.setStringList('ciudades', ciudadesString);
        
        setState(() {
          ciudadesGuardadas = Future.value(ciudadesActualizadas.map((c) {
            if (c['nombre'] == ciudad['nombre']) {
              return ciudad;
            }
            return c;
          }).toList());
        });

        debugPrint('$nombreCiudad Temperatura: $t2m °C, Viento: $windSpeed m/s');
        if(mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$nombreCiudad Temperatura: $t2m °C, Viento: $windSpeed m/s')),
          );
        }
        
    } else {
        debugPrint('Error al obtener el clima: ${response.statusCode}');  
    }
  }
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      body: ClimaCarouselView(
        ciudadesGuardadas: ciudadesGuardadas,
        actualizaClima: _actualizaClima,
      ),
    );
  }
}