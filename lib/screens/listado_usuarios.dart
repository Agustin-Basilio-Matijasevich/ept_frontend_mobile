import 'package:ept_frontend/services/businessdata.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
// import 'package:pdf/widgets.dart';

class ListadoUsuarios extends StatelessWidget {
  const ListadoUsuarios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de usuarios'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // alignment: Alignment.,
        child: const TablaUsuarios(),
      ),
    );
  }
}

class TablaUsuarios extends StatefulWidget {
  const TablaUsuarios({super.key});

  @override
  State<TablaUsuarios> createState() => _TablaUsuariosState();
}

class _TablaUsuariosState extends State<TablaUsuarios> {
  UserRoles? rolSeleccionado = UserRoles.estudiante;
  final servicio = BusinessData();

  // Future<List<_fila>> getData() async {
  //   final servicio = BusinessData();
  //   List<Map<Usuario, double>> estudianteDeuda =
  //       await servicio.listarDeudores();
  //   var dataset = <_fila>[];

  //   for (var deudor in estudianteDeuda) {
  //     var alumno = deudor.keys.first;
  //     var deuda = deudor.values.first;
  //     var tutor;
  //     try {
  //       tutor = await servicio.getPadres(alumno).then((value) => value.first);
  //     } catch (e) {
  //       tutor = null;
  //     }
  //     dataset.add(_fila(alumno: alumno, tutor: tutor, deuda: deuda));
  //   }
  //   return dataset;
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          child: DropdownMenu<UserRoles>(
            hintText: 'Filtro por rol',
            initialSelection: UserRoles.norol,
            onSelected: (value) {
              setState(
                () {
                  rolSeleccionado = value;
                },
              );
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: UserRoles.docente, label: 'Docente'),
              DropdownMenuEntry(
                  value: UserRoles.nodocente, label: 'No Docente'),
              DropdownMenuEntry(value: UserRoles.padre, label: 'Tutor'),
              DropdownMenuEntry(
                  value: UserRoles.estudiante, label: 'Estudiante'),
            ],
          ),
        ),
        FutureBuilder(
          future: servicio.listarUsuariosFiltroRol(rolSeleccionado!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.isNotEmpty) {
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre del usuario')),
                    DataColumn(label: Text('Email del usuario')),
                    DataColumn(label: Text('Foto de perfil')),
                    DataColumn(label: Text('ID del usuario')),
                  ],
                  rows: snapshot.data!.map((e) {
                    return DataRow(cells: [
                      DataCell(Text(e.nombre)),
                      DataCell(Text(e.correo)),
                      DataCell(
                        Center(
                          child: (e.foto != '')
                              ? MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (context) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Image.network(
                                              e.foto,
                                              width: 256,
                                              height: 256,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Image.network(
                                      e.foto,
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.person),
                        ),
                      ),
                      DataCell(Text(e.uid)),
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
        ),
      ],
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
