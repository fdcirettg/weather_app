import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:weather_app/agradecimiento.dart';
import 'package:weather_app/clima_carousel_view.dart';
import 'theme_provider.dart';
import 'agregar_ciudades_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MacosApp(
    title: 'Weather App',
    theme: MacosThemeData.light().copyWith(
      primaryColor: CupertinoColors.systemBlue,
    ),
    darkTheme: MacosThemeData.dark().copyWith(
      primaryColor: CupertinoColors.systemBlue,
      canvasColor: const Color(0xFF1E1E1E), 
    ),
    themeMode: themeProvider.themeMode,
    home: const MainWindow(),
    debugShowCheckedModeBanner: false,
  );
  }
}


class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}


class _MainWindowState extends State<MainWindow> {
  int _pageIndex = 0;
  bool _isLoading = true;
  
  // Variables del clima
  Future<List<Map<String, dynamic>>> ciudadesGuardadas = 
      Future<List<Map<String, dynamic>>>.value([]);
  
  static String get apiTokenUrl => 
      dotenv.env['meteomatics_api_url'] ?? 'https://login.meteomatics.com/api/v1/token';
  static String get username => dotenv.env['meteomatics_user'] ?? '';
  static String get password => dotenv.env['meteomatics_pwd'] ?? '';
  
  String apiToken = '';

  @override
  void initState() {
    super.initState();
    _inicializar();
  }
  
  Future<void> _inicializar() async {
    debugPrint('=== 🚀 Iniciando aplicación ===');
    
    // 1. Obtener token primero
    await obtenToken();
    
    // 2. Cargar ciudades
    final ciudades = await _ciudadesGuardadas();
    if (mounted) {
      setState(() {
        ciudadesGuardadas = Future.value(ciudades);
      });
    }
    
    // 3. Actualizar clima de la primera ciudad si existe
    if (ciudades.isNotEmpty && apiToken.isNotEmpty) {
      debugPrint('📍 Actualizando clima de: ${ciudades[0]['nombre']}');
      await _actualizaClima(ciudades[0]);
    } else if (ciudades.isEmpty) {
      debugPrint('ℹ️ No hay ciudades guardadas');
    }
    
    // 4. Marcar como cargado
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    
    debugPrint('=== ✅ Aplicación inicializada ===');
  }

  Future<List<Map<String, dynamic>>> _ciudadesGuardadas() async {
    debugPrint('📂 Cargando ciudades guardadas...');
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    debugPrint('Total ciudades en SharedPreferences: ${ciudadesString.length}');
    
    if (ciudadesString.isNotEmpty) {
      debugPrint('Primera ciudad: ${ciudadesString.first}');
    }
    
    return ciudadesString
        .map((ciudad) => json.decode(ciudad) as Map<String, dynamic>)
        .toList();
  }

  Future<void> obtenToken() async {
    if (apiToken.isNotEmpty) {
      debugPrint('ℹ️ Token ya existe');
      return;
    }
    
    debugPrint('🔑 Obteniendo token de autenticación...');
    
    try {
      final response = await http.get(
        Uri.parse(apiTokenUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        apiToken = data['access_token'];
        debugPrint('✅ Token obtenido exitosamente');
      } else {
        debugPrint('⚠️ Error HTTP ${response.statusCode} al obtener token');
      }
    } catch (e) {
      debugPrint('❌ Excepción al obtener token: $e');
    }
  }

  Future<void> _actualizaClima(Map<String, dynamic> ciudad, {bool forzarActualizacion = false}) async {
    String nombreCiudad = ciudad['nombre'] ?? 'Desconocida';
    debugPrint('🌤️ Actualizando clima para $nombreCiudad');
    
    if (apiToken.isEmpty) {
      debugPrint('⚠️ No se puede actualizar el clima sin un token válido.');
      return;
    }
    
    bool actualizar = forzarActualizacion; // Si se fuerza, ya es true
    double latitud = ciudad['latitud'] ?? 0.0;
    double longitud = ciudad['longitud'] ?? 0.0;
    
    // Solo verificar el tiempo si NO se está forzando la actualización
    if (!forzarActualizacion) {
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
        } else {
          debugPrint('ℹ️ Clima aún vigente (actualizado hace ${diferencia.inMinutes} minutos)');
        }
      }
    } else {
      debugPrint('🔄 Forzando actualización manual del clima');
    }
    
    if (!actualizar) {
      debugPrint('ℹ️ No es necesario actualizar el clima de $nombreCiudad');
      return;
    }
    
    String hora_actualZ = DateTime.now().toUtc().toIso8601String();
    String url = 'https://api.meteomatics.com/$hora_actualZ/t_2m:C,wind_speed_10m:ms,weather_symbol_1h:idx/$latitud,$longitud/json?access_token=$apiToken';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final climaData = json.decode(response.body);
        final data = climaData['data'];
        
        final t2m = data[0]['coordinates'][0]['dates'][0]['value'];
        final windSpeed = data[1]['coordinates'][0]['dates'][0]['value'];
        final weatherSymbol = data[2]['coordinates'][0]['dates'][0]['value'];
        String ultimaActualizacion = data[0]['coordinates'][0]['dates'][0]['date'];
        
        debugPrint('🌥️ Temperatura: $t2m°C, Viento: $windSpeed m/s, Símbolo: $weatherSymbol');
        
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
        
        if (mounted) {
          setState(() {
            ciudadesGuardadas = Future.value(ciudadesActualizadas.map((c) {
              if (c['nombre'] == ciudad['nombre']) {
                return ciudad;
              }
              return c;
            }).toList());
          });
        }

        debugPrint('✅ Clima actualizado para $nombreCiudad');
      } else {
        debugPrint('⚠️ Error al obtener el clima: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar clima: $e');
    }
  }

  Future<void> _refreshCiudades() async {
    debugPrint('=== 🔄 Refrescando ciudades ===');
    final ciudadesActualizadas = await _ciudadesGuardadas();
    
    if (mounted) {
      setState(() {
        ciudadesGuardadas = Future.value(ciudadesActualizadas);
      });
    }
    
    // Si hay ciudades y la última no tiene datos del clima, actualizarla
    if (ciudadesActualizadas.isNotEmpty) {
      final ultimaCiudad = ciudadesActualizadas.last;
      
      // Verificar si la ciudad no tiene datos del clima
      if (ultimaCiudad['temperatura'] == null || 
          ultimaCiudad['ultima_actualizacion'] == null) {
        debugPrint('⏳ Obteniendo clima para ciudad nueva: ${ultimaCiudad['nombre']}');
        
        // Esperar un momento para que el token esté disponible
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Actualizar el clima de la nueva ciudad
        await _actualizaClima(ultimaCiudad);
        
        debugPrint('✅ Clima actualizado para: ${ultimaCiudad['nombre']}');
      }
    }
    
    debugPrint('=== ✅ Fin refresco ciudades ===');
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se inicializa
    if (_isLoading) {
      return MacosWindow(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MacosTheme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.blue.shade50,
                MacosTheme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.blue.shade100,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.cloud_sun,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const ProgressCircle(),
                const SizedBox(height: 16),
                Text(
                  'Inicializando Weather App...',
                  style: MacosTheme.of(context).typography.headline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Obteniendo datos del clima',
                  style: MacosTheme.of(context).typography.body.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Mostrar la interfaz normal una vez cargado
    return PlatformMenuBar(
      menus: _buildMenuBar(),
      child: MacosWindow(
        sidebar: Sidebar(
          minWidth: 200,
          builder: (context, scrollController) {
            return SidebarItems(
              currentIndex: _pageIndex,
              scrollController: scrollController,
              itemSize: SidebarItemSize.large,
              onChanged: (index) {
                setState(() => _pageIndex = index);
              },
              items: const [
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.cloud_sun),
                  label: Text('Clima'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.add),
                  label: Text('Agregar Ciudades'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.info),
                  label: Text('Agradecimientos'),
                ),
              ],
            );
          },
          bottom: _buildSidebarBottom(),
        ),
        child: IndexedStack(
          index: _pageIndex,
          children: [
            // Página de Clima
            _buildClimaPage(),
            // Página de Agregar Ciudades
            AgregarCiudadesPage(onCiudadAgregada: _refreshCiudades),
            const AgradecimientosPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildClimaPage() {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Clima'),
        titleWidth: 150,
        actions: [
          ToolBarIconButton(
            label: 'Refrescar',
            icon: const MacosIcon(CupertinoIcons.refresh),
            onPressed: () async {
              final ciudades = await ciudadesGuardadas;
              if (ciudades.isNotEmpty) {
                // Pasar forzarActualizacion: true para actualizar inmediatamente
                await _actualizaClima(ciudades[0], forzarActualizacion: true);
              }
            },
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return ClimaCarouselView(
              ciudadesGuardadas: ciudadesGuardadas,
              actualizaClima: _actualizaClima,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSidebarBottom() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MacosTooltip(
                message: 'Cambiar tema',
                child: MacosIconButton(
                  icon: MacosIcon(
                    Provider.of<ThemeProvider>(context).isDarkMode
                        ? CupertinoIcons.moon_fill
                        : CupertinoIcons.sun_max_fill,
                  ),
                  onPressed: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                ),
              ),
              const SizedBox(width: 8),
              MacosTooltip(
                message: 'Configuración',
                child: MacosIconButton(
                  icon: const MacosIcon(CupertinoIcons.settings),
                  onPressed: () {
                    debugPrint('Configuración');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PlatformMenu> _buildMenuBar() {
    return [
      PlatformMenu(
        label: 'Weather App',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Acerca de Weather App',
                onSelected: () {
                  showMacosAlertDialog(
                    context: context,
                    builder: (_) => MacosAlertDialog(
                      appIcon: const Icon(
                        CupertinoIcons.cloud_sun,
                        size: 64,
                        color: Colors.blue,
                      ),
                      title: const Text('Weather App'),
                      message: const Text(
                        'Una aplicación moderna de clima para macOS\n\nVersión 1.0.0',
                        textAlign: TextAlign.center,
                      ),
                      primaryButton: PushButton(
                        controlSize: ControlSize.large,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.quit))
                const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit,
                ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: 'Ver',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Cambiar Tema',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyT,
                  meta: true,
                ),
                onSelected: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: 'Ciudades',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Agregar Ciudad',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyN,
                  meta: true,
                ),
                onSelected: () {
                  setState(() => _pageIndex = 1);
                },
              ),
              PlatformMenuItem(
                label: 'Actualizar Clima',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyR,
                  meta: true,
                ),
                onSelected: () async {
                  final ciudades = await ciudadesGuardadas;
                  if (ciudades.isNotEmpty) {
                    await _actualizaClima(ciudades[0], forzarActualizacion: true);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
