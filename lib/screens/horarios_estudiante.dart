import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';
import '../services/businessdata.dart';

// PARA ESTUDIANTES Y DOCENTES
class Horarios extends StatelessWidget {
  const Horarios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: const GrillaHorarios(),
      ),
    );
  }
}

class GrillaHorarios extends StatefulWidget {
  const GrillaHorarios({super.key});

  @override
  State<GrillaHorarios> createState() => GrillaHorariosState();
}

class GrillaHorariosState extends State<GrillaHorarios> {
  final servicio = BusinessData();

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    return FutureBuilder(
      future: servicio.getCursosPorUsuario(usuario),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
          return DataTable(
            columns: const [
              DataColumn(label: Text('Curso')),
              DataColumn(label: Text('Aula')),
              DataColumn(label: Text('Dia')),
              DataColumn(label: Text('Hora inicio')),
              DataColumn(label: Text('Hora fin')),
            ],
            rows: snapshot.data!
                .map(
                  (e) => DataRow(cells: [
                    DataCell(Text(e.nombre)),
                    DataCell(Text(e.aula)),
                    DataCell(Text(e.dia.name)),
                    DataCell(Text(
                        '${e.horainicio.hour}:${e.horainicio.minute.toString().padLeft(2, '0')}')),
                    DataCell(Text(
                        '${e.horafin.hour}:${e.horafin.minute.toString().padLeft(2, '0')}')),
                  ]),
                )
                .toList(),
          );
        } else if (snapshot.data != null && snapshot.data!.isEmpty) {
          return const Text('No se encontraron datos para mostrar');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return const Text('Ocurrio un error');
        }
      },
    );
  }
}
