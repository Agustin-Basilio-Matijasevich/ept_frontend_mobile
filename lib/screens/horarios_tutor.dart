import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';
import '../services/businessdata.dart';

class HorariosTutor extends StatelessWidget {
  const HorariosTutor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.topCenter,
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
  Usuario? estudianteSeleccionado;
  final servicio = BusinessData();

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    return Column(
      children: [
        FutureBuilder(
          future: servicio.getHijos(usuario!),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return DropdownMenu(
                onSelected: (value) {
                  setState(() {
                    estudianteSeleccionado = value;
                  });
                },
                hintText: 'Seleccione un hijo',
                dropdownMenuEntries: snapshot.data!
                    .map((e) => DropdownMenuEntry(label: e.nombre, value: e))
                    .toList(),
              );
            } else if (snapshot.data != null && snapshot.data!.isEmpty) {
              return const Text('No se encontraron hijos para mostrar');
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              return const Text('Ocurrio un error');
            }
          },
        ),
        FutureBuilder(
          future: servicio.getCursosPorUsuario(estudianteSeleccionado),
          builder: (context, snapshot) {
            if (estudianteSeleccionado == null) {
              return const SizedBox();
            }
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
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
                    ),
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.data != null && snapshot.data!.isEmpty) {
              return const Text('No se encontraron datos para mostrar');
            } else {
              return const Text('Ocurrio un error');
            }
          },
        )
      ],
    );
  }
}
