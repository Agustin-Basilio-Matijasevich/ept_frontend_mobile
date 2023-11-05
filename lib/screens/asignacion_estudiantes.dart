import 'package:ept_frontend/services/businessdata.dart';
import 'package:flutter/material.dart';

import '../models/curso.dart';
import '../models/usuario.dart';

class AsignacionEstudiantes extends StatelessWidget {
  const AsignacionEstudiantes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignacion de estudiantes'),
      ),
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
  Set<Curso> cursosSeleccionados = {};
  final servicio = BusinessData();

  List<Usuario>? docentes;
  List<Curso>? cursos;

  Future<bool> asignarListaCursos(
      Usuario estudiante, List<Curso> cursos) async {
    bool result = true;
    for (var curso in cursos) {
      bool response =
          await servicio.adherirCurso(estudianteSeleccionado!, curso);
      if (!response) result = false;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text('Seleccione un estudiante'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height - 200,
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder(
                    future:
                        servicio.listarUsuariosFiltroRol(UserRoles.estudiante),
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
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
                          ],
                          rows: snapshot.data!
                              .map(
                                (e) => DataRow(
                                    selected:
                                        e.uid == estudianteSeleccionado?.uid,
                                    onSelectChanged: (value) {
                                      setState(() {
                                        estudianteSeleccionado = e;
                                      });
                                    },
                                    cells: [
                                      DataCell(Text(e.nombre)),
                                      DataCell(Text(e.correo)),
                                    ]),
                              )
                              .toList(),
                        );
                      } else {
                        return const Text('No se encontraron estudiantes');
                      }
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text('Seleccione varios cursos'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height - 200,
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder(
                    future: servicio.getCursos(),
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
                                  (e) => DataRow(
                                      selected: cursosSeleccionados.any(
                                          (element) =>
                                              element.nombre == e.nombre),
                                      onSelectChanged: (value) {
                                        if (value!) {
                                          setState(() {
                                            cursosSeleccionados.add(e);
                                          });
                                        } else {
                                          setState(() {
                                            cursosSeleccionados.removeWhere(
                                              (element) =>
                                                  element.nombre == e.nombre,
                                            );
                                          });
                                        }
                                      },
                                      cells: [
                                        DataCell(Text(e.nombre)),
                                        DataCell(Text(e.aula)),
                                        DataCell(Text(e.dia.name)),
                                        DataCell(Text(
                                            '${e.horainicio.hour}:${e.horainicio.minute.toString().padLeft(2, '0')}')),
                                        DataCell(Text(
                                            '${e.horafin.hour}:${e.horafin.minute.toString().padLeft(2, '0')}')),
                                      ]),
                                )
                                .toList());
                      } else {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          return const Text('No se encontraron cursos');
                        }
                      }
                    },
                  ),
                ),
              ],
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
            if (estudianteSeleccionado != null &&
                cursosSeleccionados.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) => FutureBuilder(
                  future: asignarListaCursos(
                      estudianteSeleccionado!, cursosSeleccionados.toList()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String mensaje = '';
                      if (snapshot.data!) {
                        mensaje = 'Exito asignando los cursos al estudiante';
                      } else {
                        mensaje =
                            'Ocurrio un error asignando los cursos al estudiante';
                      }
                      return AlertDialog(
                        title: const Text('Resultado de asignacion'),
                        content: Text(mensaje),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        alignment: Alignment.center,
                        width: 64,
                        height: 64,
                        child: const CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Text('Asignar estudiante'),
          ),
        ),
      ],
    );
  }
}
