import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class AgradecimientosPage extends StatefulWidget {
  const AgradecimientosPage({super.key});

  @override
  State<AgradecimientosPage> createState() => _AgradecimientosPageState();
}

class _AgradecimientosPageState extends State<AgradecimientosPage> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Agradecimientos'),
        titleWidth: 150,
        actions: [
          // Nada xd
        ],
      ),
      
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildSeccion(
                    titulo: 'Servicios Utilizados',
                    children: [
                      _buildItemLista(
                        icono: CupertinoIcons.cloud_sun,
                        titulo: 'Meteomatics',
                        subtitulo: 'Agradezco a Meteomatics por proporcionar datos meteorológicos precisos y confiables.',
                      ),
                      _buildItemLista(
                        icono: CupertinoIcons.map,
                        titulo: 'OpenStreetMap',
                        subtitulo: 'Agradezco a OpenStreetMap por ofrecer información geográfica abierta y colaborativa.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSeccion(
                    titulo: 'Integrantes del Equipo',
                    children: [
                      _buildItemLista(
                        icono: CupertinoIcons.person,
                        titulo: 'Quijada Castillo Juan Diego',
                        subtitulo: 'Codeando ando',
                      ),
                      _buildItemLista(
                        icono: CupertinoIcons.person,
                        titulo: 'Luis Alberto Morales Medina',
                        subtitulo: 'Me llaman Chino',
                      ),
                    ],
                  ),
                  
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: MacosTheme.of(context).typography.title3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: MacosTheme.of(context).brightness == Brightness.dark
                ? CupertinoColors.systemGrey6.darkColor.withOpacity(0.3)
                : CupertinoColors.systemGrey6.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: MacosTheme.of(context).brightness == Brightness.dark
                  ? CupertinoColors.systemGrey4.darkColor
                  : CupertinoColors.systemGrey4.color,
              width: 0.5,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildItemLista({
    required IconData icono,
    required String titulo,
    String? subtitulo,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              MacosIcon(
                icono,
                size: 24,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: MacosTheme.of(context).typography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: MacosTheme.of(context).typography.caption1.copyWith(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const MacosIcon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
  

}
