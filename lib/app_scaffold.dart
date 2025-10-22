import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  static Future<String?> _getCustomText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_text') ?? 'Menú';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: FutureBuilder<String?>(
                future: _getCustomText(),
              builder: (context, snapshot) {
                final drawerText = snapshot.data ?? 'Menú';
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    SizedBox(height: 8),
                    Text(drawerText, style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 8),
                    
                  ],
                );
              },
            ),
            ),
            ListTile(
              leading: const Icon(Icons.sunny),
              title: const Text('Inicio'),
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Agregar Ciudades'),
              onTap: () {
                context.go('/agregar_ciudades');
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}