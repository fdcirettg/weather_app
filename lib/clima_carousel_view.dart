import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class ClimaCarouselView extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> ciudadesGuardadas;
  final Function(Map<String, dynamic>) actualizaClima;
  consts ClimaCarouselView({
    Key? key,
    required this.ciudadesGuardadas,
    required this.actualizaClima,
  }) : super(key: key);
  @override
  State<ClimaCarouselView> createState() => _ClimaCarouselViewState();
}
class _ClimaCarouselViewState extends State<ClimaCarouselView> {
  int _currentIndex = 0; // Índice de la página actual en el PageView

  // Mapa de íconos del clima
  IconData _obtenerIconoClima(int simbolo) {
    switch (simbolo) {
      case 0:
        return WeatherIcons.na;
      case 1:
        return WeatherIcons.day_sunny;
      case 2:
        return WeatherIcons.day_sunny_overcast;
      case 3:
        return WeatherIcons.day_cloudy;
      case 4:
        return WeatherIcons.cloud;
      case 101:
        return WeatherIcons.night_clear;
      case 102:
        return WeatherIcons.night_alt_cloudy_gusts;
      case 103:
        return WeatherIcons.night_partly_cloudy;
      case 104:
        return WeatherIcons.night_cloudy;
      default:
        return WeatherIcons.na;
    }
  }
  String _obtenerDescripcionClima(int simbolo) {
    switch (simbolo) {
      case 0:
         return 'Sin datos';

      case 1:
        return 'Despejado';
      case 2:
        return 'Mayormente despejado';
      case 3:
        return 'Parcialmente Nublado';
      case 4:
        return 'Nublado';
      case 101:
        return 'Despejado (noche)';
      case 102:
        return 'Mayormente despejado (noche)';
      case 103:
        return 'Parcialmente nublado (noche)';
      case 104:
        return 'Nublado (noche)';
      default:
        return 'Desconocido';
    }
  }
  String  _formatearHora(String? timestamp) {
      if (timestamp == null || timestamp.isEmpty) return 'Desconocido';
      try {
        final fecha = DateTime.parse(timestamp);
        return DateFormat('HH:mm').format(fecha.toLocal());
      } catch (e) {
        return 'Desconocido';
      }
    }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.ciudadesGuardadas,
      builder: (context, snapshot) {
        // Mostrar 'Loading' mientras se cargan los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        // Manejar errores
        if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  Text('Error al cargar ciudades: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)
                    ),
                    const SizedBox(height:10),
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        }
        // Acceder a la lista de ciudades
        final ciudades = snapshot.data ?? [];
        if (ciudades.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(height: 20,),
                  Text(
                    'No hay ciudades guardadas',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        }
        // Mostrar el Carousel de ciudades
        return _buildCarousel(ciudades);
      },
    );
  }
}
Widget _buildCarousel(List<Map<String, dynamic>> ciudades) {
  return Container(); // Implementación del carrusel aquí
}