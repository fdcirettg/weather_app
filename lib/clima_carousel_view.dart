import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart'; 

class ClimaCarouselView extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> ciudadesGuardadas;
  final Function(Map<String, dynamic>) actualizaClima;
  const ClimaCarouselView({
    Key? key,
    required this.ciudadesGuardadas,
    required this.actualizaClima,
  }) : super(key: key);
  @override
  State<ClimaCarouselView> createState() => _ClimaCarouselViewState();
}
class _ClimaCarouselViewState extends State<ClimaCarouselView> {
  int _currentIndex = 0; 

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
        return _buildCarousel(ciudades);
      },
    );
  }

  Widget _buildCarousel(List<Map<String, dynamic>> ciudades) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: ciudades.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.actualizaClima(ciudades[index]);
            },
            itemBuilder: (context, index) {
              final ciudad = ciudades[index];
              final temperatura = ciudad['temperatura']?.toStringAsFixed(1) ?? '--';
              final viento = ciudad['velocidad_viento']?.toStringAsFixed(1) ?? '--';
              final simbolo = ciudad['simbolo_clima'] ?? 0;
              final nombre = ciudad['nombre'] ?? 'Ciudad desconocida';
              final ultimaActualizacion = ciudad['ultima_actualizacion'] ?? '';
              
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      Icon(
                        _obtenerIconoClima(simbolo),
                        size: 120,
                        color: Colors.white,
                      ),
                      
                      Text(
                        '$temperatura°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      Text(
                        _obtenerDescripcionClima(simbolo),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 24,
                        ),
                      ),
                      
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.air, color: Colors.white, size: 30),
                                const SizedBox(height: 8),
                                Text(
                                  '$viento m/s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Viento',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.access_time, color: Colors.white, size: 30),
                                const SizedBox(height: 8),
                                Text(
                                  _formatearHora(ultimaActualizacion),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Actualizado',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              ciudades.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 12 : 8,
                height: _currentIndex == index ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


}