import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgregarCiudadesPage extends StatelessWidget {
  const AgregarCiudadesPage({super.key});

  @override
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
}
