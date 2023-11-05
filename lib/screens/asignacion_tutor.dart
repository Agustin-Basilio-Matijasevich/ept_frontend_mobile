import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/businessdata.dart';

// Ta enorme esta pantalla :(
class AsignacionTutor extends StatelessWidget {
  const AsignacionTutor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignacion de tutores')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.topCenter,
        child: const Contenido(),
      ),
    );
  }
}

class Contenido extends StatefulWidget {
  const Contenido({super.key});

  @override
  State<Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<Contenido> {
  Usuario? estudianteSeleccionado;
  String? filtroEstudiante;
  Usuario? tutorSeleccionado;
  String? filtroTutor;
  final servicio = BusinessData();
  @override
  Widget build(BuildContext context) {
    // Fila para mostrar 2 columnas con grilla y filtro de busqueda
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Columna para estudiantes
            Container(
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Filtro
                  SizedBox(
                    width: 100,
                    // height: 100,
                    child: TextField(
                      decoration:
                          const InputDecoration(hintText: 'Filtrar por nombre'),
                      autocorrect: false,
                      enabled: true,
                      onSubmitted: (value) {
                        setState(() {
                          filtroEstudiante = value;
                        });
                      },
                    ),
                  ),
                  // Tabla
                  FutureBuilder(
                    future:
                        servicio.listarUsuariosFiltroRol(UserRoles.estudiante),
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                        var dataset = (filtroEstudiante == null)
                            ? snapshot.data
                            : snapshot.data!.where((element) => element.nombre
                                .toLowerCase()
                                .contains(filtroEstudiante!.toLowerCase()));
                        if (dataset != null && dataset.isNotEmpty) {
                          return DataTable(
                            showCheckboxColumn: true,
                            onSelectAll: (value) {
                              setState(() {
                                estudianteSeleccionado = null;
                              });
                            },
                            columns: const [
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Correo')),
                              DataColumn(label: Text('UID')),
                            ],
                            rows: dataset
                                .map(
                                  (e) => DataRow(
                                    selected:
                                        estudianteSeleccionado?.uid == e.uid,
                                    onSelectChanged: (value) {
                                      setState(() {
                                        estudianteSeleccionado = e;
                                      });
                                    },
                                    cells: [
                                      DataCell(Text(e.nombre)),
                                      DataCell(Text(e.correo)),
                                      DataCell(Text(e.uid)),
                                    ],
                                  ),
                                )
                                .toList(),
                          );
                        } else {
                          return const Text(
                              'No se encontraron datos para mostrar');
                        }
                      } else if (snapshot.data != null &&
                          snapshot.data!.isEmpty) {
                        return const Text(
                            'No se encontraron datos para mostrar');
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        return const Text('Ocurrio un error :(');
                      }
                    },
                  ),
                ],
              ),
            ),

            // Columna para tutores
            Container(
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Filtro
                  SizedBox(
                    width: 100,
                    // height: 100,
                    child: TextField(
                      decoration:
                          const InputDecoration(hintText: 'Filtrar por nombre'),
                      autocorrect: false,
                      enabled: true,
                      onSubmitted: (value) {
                        setState(() {
                          filtroEstudiante = value;
                        });
                      },
                    ),
                  ),
                  // Tabla
                  FutureBuilder(
                    future: servicio.listarUsuariosFiltroRol(UserRoles.padre),
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                        var dataset = (filtroTutor == null)
                            ? snapshot.data
                            : snapshot.data!.where((element) => element.nombre
                                .toLowerCase()
                                .contains(filtroTutor!.toLowerCase()));
                        if (dataset!.isNotEmpty) {
                          return DataTable(
                            showCheckboxColumn: true,
                            onSelectAll: (value) {
                              setState(() {
                                tutorSeleccionado = null;
                              });
                            },
                            columns: const [
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Correo')),
                              DataColumn(label: Text('UID')),
                            ],
                            rows: dataset
                                .map(
                                  (e) => DataRow(
                                    selected: tutorSeleccionado?.uid == e.uid,
                                    onSelectChanged: (value) {
                                      setState(() {
                                        tutorSeleccionado = e;
                                      });
                                    },
                                    cells: [
                                      DataCell(Text(e.nombre)),
                                      DataCell(Text(e.correo)),
                                      DataCell(Text(e.uid)),
                                    ],
                                  ),
                                )
                                .toList(),
                          );
                        } else {
                          return const Text(
                              'No se encontraron usuarios con ese nombre');
                        }
                      } else if (snapshot.data != null &&
                          snapshot.data!.isEmpty) {
                        return const Text(
                            'No se encontraron datos para mostrar');
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        return const Text('Error');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        TextButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.blue),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 24)),
          ),
          onPressed: () {
            if (estudianteSeleccionado != null && tutorSeleccionado != null) {
              showDialog(
                context: context,
                builder: (context) {
                  return FutureBuilder(
                    future: servicio.asignarHijo(
                        tutorSeleccionado!, estudianteSeleccionado!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        String mensaje = '';
                        if (snapshot.data!) {
                          mensaje = 'Exito en la vinculacion de padre-hijo';
                        } else {
                          mensaje = 'Ocurrio un error en la vinculacion';
                        }
                        return AlertDialog(
                          title: const Text('Resultado de vinculacion'),
                          content: Text(mensaje),
                          actions: [
                            TextButton(
                              child: const Text('Aceptar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      } else {
                        return Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                },
              );
            }
          },
          child: const Text('Asignar hijo-tutor'),
        ),
      ],
    );
  }
}
