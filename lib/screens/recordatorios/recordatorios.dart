import 'package:ept_frontend/widgets/expanded_panel_list/recordatorio_panel_list.dart';
import 'package:flutter/material.dart';

import 'agregar_recordatorio.dart';

class Recordatorios extends StatelessWidget {
  const Recordatorios({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => RecordatoriosPanelList(
          constraints: constraints,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const AgregarRecordatorio(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.blue, // <-- Button color
            foregroundColor: Colors.red, // <-- Splash color
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class RecordatoriosContent extends StatefulWidget {
  const RecordatoriosContent({super.key});

  @override
  State<RecordatoriosContent> createState() => _RecordatoriosContentState();
}

class _RecordatoriosContentState extends State<RecordatoriosContent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
