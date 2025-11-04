import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app_scaffold.dart';
import 'theme_provider.dart';
import 'agregar_ciudades_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  
// Cargamos url, user  y pass desde el archivo .env
  static String get apiTokenUrl => dotenv.env['meteomatics_api_url'] ?? 'https://login.meteomatics.com/api/v1/token';
  static String get username => dotenv.env['meteomatics_user'] ?? '';
  static String get password => dotenv.env['meteomatics_pwd'] ?? '';
  String apiToken = '';
@override
  void initState() {
    super.initState();
    debugPrint('API URL: $apiTokenUrl');
    debugPrint('Username: $username');
    // imprime la contraseña de forma segura sin mostrarla completa
    debugPrint('Password: ${'*' * password.length}');
    // aquí vamos a llamar a la función para obtener el token
    // obtenerToken();
    // acá vamos a cargar las ciudades guardadas
    // ciudadesGuardadas = _ciudadesGuardadas();
  }

  void obtenToken() async {
    // Lógica para obtener el token de la API usando apiTokenUrl, username y password
    // y luego asignarlo a la variable apiToken
    // Si ya tenemos el token, no hacemos nada
    if (apiToken.isNotEmpty) return;
    // Aquí iría la lógica real para obtener el token
    }
    
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Weather App",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Divider(color: Colors.grey.shade300),

        ],
      ),
    );
  }
}