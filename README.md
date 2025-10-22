# weather_app

Aplicación del Clima en Flutter

## Recursos en línea

Utilizaremos recursos de **Nominatim** para hacer Geocoding, es decir, extraer latitud y longitud con solo proporcionar el nombre de una ciudad:

Uso de Nominatim para obtener coordenadas de las ciudades:
 Nominatim
- [API de Nominatim(https://nominatim.org/release-docs/develop/api/Overview/)]
- [Búsqueda de ciudades(https://nominatim.org/release-docs/develop/api/Search/)]
- Ejemplos de uso:
- Nogales, Sonora: [https://nominatim.openstreetmap.org/search?q=Nogales+Sonora&format=jsonv2&limit=1]
- Ciudad de México: [https://nominatim.openstreetmap.org/search?q=ciudad+de+mexico&format=jsonv2&limit=1]

Para obtener datos del clima, nos ayudaremos de una cuenta gratis en **Meteo Matics**, empresa proveedora de servicios de climatología.

- Temperatura
[https://www.meteomatics.com/en/api/available-parameters/weather-parameter/temperature/#immediate_temperature]
- Viento
[https://www.meteomatics.com/en/api/available-parameters/weather-parameter/standard-weather-parameters-wind/]
- Cómo obtener el forecast o predicción del clima para 3 lugares a la vez:
[https://www.meteomatics.com/en/api/faq/#temperature_at_3_locations]
- Símbolos del clima y códigos
[https://www.meteomatics.com/en/api/available-parameters/weather-parameter/general-weather-state/]
- Ejemplo de uso de la API de Meteo Matics:
[https://api.meteomatics.com/2025-10-21T22:15:00Z/t_2m:C,wind_speed_10m:ms,weather_symbol_1h:idx/29.091,-110.955/json]
