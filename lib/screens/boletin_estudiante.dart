// import 'package:ept_frontend/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../models/curso.dart';
import '../models/usuario.dart';
import '../services/businessdata.dart';

class BoletinEstudiante extends StatelessWidget {
  const BoletinEstudiante({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boletin'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: GrillaBoletin(),
      ),
    );
  }
}

class GrillaBoletin extends StatefulWidget {
  GrillaBoletin({super.key});
  final servicio = BusinessData();

  @override
  State<GrillaBoletin> createState() => _GrillaBoletinState();
}

class _GrillaBoletinState extends State<GrillaBoletin> {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    return FutureBuilder(
      future: widget.servicio.getPromedioPorCurso(usuario!, 2023),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
          var columns = const [
            DataColumn(label: Text('Curso')),
            DataColumn(label: Text('1 Tri.')),
            DataColumn(label: Text('2 Tri.')),
            DataColumn(label: Text('3 Tri.')),
            DataColumn(label: Text('Promedio')),
          ];

          var rows = <DataRow>[];
          // Itera por curso
          for (var curso in snapshot.data!) {
            var nombreCurso = curso.keys.first.nombre;
            var notas = curso.values.first;
            int sumatoria = 0;
            int cantNotas = 0;
            for (var nota in notas) {
              if (nota != null) {
                cantNotas++;
                sumatoria += nota;
              }
            }

            int promedio =
                (sumatoria / ((cantNotas == 0) ? 1 : cantNotas)).round();

            rows.add(
              DataRow(
                cells: [
                  DataCell(Text(nombreCurso)),
                  DataCell(Text((notas[0] != null) ? notas[0].toString() : '')),
                  DataCell(Text((notas[1] != null) ? notas[1].toString() : '')),
                  DataCell(Text((notas[2] != null) ? notas[2].toString() : '')),
                  DataCell(Text((cantNotas == 0) ? '' : promedio.toString())),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(columns: columns, rows: rows),
            ),
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
