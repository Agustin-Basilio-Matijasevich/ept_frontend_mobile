import 'package:ept_frontend/models/usuario.dart';
import 'package:ept_frontend/services/businessdata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Deuda extends StatelessWidget {
  const Deuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deuda'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: const DeudaContenido(),
      ),
    );
  }
}

class DeudaContenido extends StatefulWidget {
  const DeudaContenido({super.key});

  @override
  State<DeudaContenido> createState() => _DeudaContenidoState();
}

class _DeudaContenidoState extends State<DeudaContenido> {
  final servicio = BusinessData();

  Future<List<Map<Usuario, double>>> getDeudas(Usuario usuario) async {
    List<Map<Usuario, double>> deudas = [];
    var hijos = await servicio.getHijos(usuario);
    for (var hijo in hijos) {
      var deuda = await servicio.getDeuda(hijo);
      if (deuda > 0) {
        deudas.add({hijo: deuda});
      }
    }
    return deudas;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario>(context);
    return FutureBuilder(
      future: getDeudas(usuario),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return DataTable(
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Deuda')),
              ],
              rows: snapshot.data!
                  .map(
                    (e) => DataRow(cells: [
                      DataCell(Text(e.keys.first.nombre)),
                      DataCell(Text(e.values.first.toStringAsFixed(2))),
                    ]),
                  )
                  .toList(),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Text('Usted no posee deuda');
          } else {
            return const Text('Ocurrio un error');
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
