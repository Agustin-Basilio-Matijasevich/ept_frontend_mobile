import 'package:flutter/material.dart';

import '../services/businessdata.dart';

class ListadoCursos extends StatelessWidget {
  const ListadoCursos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de cursos'),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.topCenter,
          child: const GrillaCursos()),
    );
  }
}

class GrillaCursos extends StatefulWidget {
  const GrillaCursos({super.key});

  @override
  State<GrillaCursos> createState() => GrillaCursosState();
}

class GrillaCursosState extends State<GrillaCursos> {
  final servicio = BusinessData();
  String textoFiltro = '';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextField(
            onSubmitted: (value) {
              setState(() {
                textoFiltro = value;
              });
            },
          ),
          FutureBuilder(
            future: servicio.getCursos(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Dia de la semana')),
                    DataColumn(label: Text('Hora de inicio')),
                    DataColumn(label: Text('Hora de fin')),
                    DataColumn(label: Text('Aula')),
                  ],
                  rows: snapshot.data!.map(
                    (e) {
                      return DataRow(cells: [
                        DataCell(Text(e.nombre)),
                        DataCell(Text(e.dia.name)),
                        DataCell(Text(
                            '${e.horainicio.hour}:${e.horainicio.minute.toString().padLeft(2, '0')}')),
                        DataCell(Text(
                            '${e.horafin.hour}:${e.horafin.minute.toString().padLeft(2, '0')}')),
                        DataCell(Text(e.aula)),
                      ]);
                    },
                  ).toList(),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Text('No se encontraron datos para mostrar');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Text('Ocurrio un error');
              }
            },
          ),
        ],
      ),
    );
  }
}
