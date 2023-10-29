import 'package:ept_frontend/screens/pago_cuotas.dart';
import 'package:ept_frontend/services/businessdata.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
// import 'package:pdf/widgets.dart';

class Deudores extends StatelessWidget {
  const Deudores({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudores'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.topCenter,
        child: const TablaDeudores(),
      ),
    );
  }
}

class TablaDeudores extends StatefulWidget {
  const TablaDeudores({super.key});

  @override
  State<TablaDeudores> createState() => _TablaDeudoresState();
}

class _TablaDeudoresState extends State<TablaDeudores> {
  var ejemplo = [];
  final servicio = BusinessData();

  Future<List<Fila>> getData() async {
    final servicio = BusinessData();
    List<Map<Usuario, double>> estudianteDeuda =
        await servicio.listarDeudores();
    var dataset = <Fila>[];

    for (var deudor in estudianteDeuda) {
      Usuario alumno = deudor.keys.first;
      double deuda = deudor.values.first;
      Usuario? tutor;
      try {
        tutor = await servicio.getPadres(alumno).then((value) => value.first);
      } catch (e) {
        tutor = null;
      }
      dataset.add(Fila(alumno: alumno, tutor: tutor, deuda: deuda));
    }
    return dataset;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data!.isNotEmpty) {
            return DataTable(
              columns: const [
                DataColumn(label: Text('Nombre del Alumno')),
                DataColumn(label: Text('Email del Alumno')),
                DataColumn(label: Text('Nombre del Tutor')),
                DataColumn(label: Text('Email del tutor')),
                DataColumn(label: Text('Monto de deuda')),
                DataColumn(label: Text('Generar pago')),
              ],
              rows: snapshot.data!.map((e) {
                return DataRow(cells: [
                  DataCell(Text(e.alumno.nombre)),
                  DataCell(Text(e.alumno.correo)),
                  DataCell(Text((e.tutor != null) ? e.tutor!.nombre : '')),
                  DataCell(Text((e.tutor != null) ? e.tutor!.correo : '')),
                  DataCell(Text(e.deuda.toString())),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => PagoCuotas(
                              deudor: e.alumno,
                              deuda: e.deuda,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ]);
              }).toList(),
            );
          }
          return const Text('No hay deudores para mostrar');
        } else {
          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class Fila {
  Usuario alumno;
  Usuario? tutor;
  double deuda;
  Fila({
    required this.alumno,
    this.tutor,
    required this.deuda,
  });
}
