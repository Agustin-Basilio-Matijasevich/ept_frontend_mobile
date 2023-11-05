import 'package:ept_frontend/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ept_frontend/services/businessdata.dart';

import '../models/curso.dart';
import '../models/usuario.dart';

class Notas extends StatelessWidget {
  const Notas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: const GrillaNotas(),
      ),
    );
  }
}

class GrillaNotas extends StatefulWidget {
  const GrillaNotas({super.key});

  @override
  State<GrillaNotas> createState() => _GrillaNotasState();
}

class _GrillaNotasState extends State<GrillaNotas> {
  Curso? cursoSeleccionado;
  Set<Map<Usuario, Nota>> notas = {};
  final servicio = BusinessData();

  Future<bool> cargarListaNotas(
      Curso curso, Set<Map<Usuario, Nota>> notas) async {
    bool result = true;
    for (var nota in notas) {
      bool finalizacion = await servicio.cargarNota(
        nota.keys.first,
        curso,
        nota.values.first,
      );
      if (!finalizacion) result = false;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);

    return Column(
      children: [
        // Selector de Cursos
        FutureBuilder(
          future: servicio.getCursosPorUsuario(usuario!),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: DropdownMenu<Curso>(
                  hintText: 'Seleccione un curso',
                  onSelected: (value) {
                    setState(() {
                      cursoSeleccionado = value;
                    });
                  },
                  dropdownMenuEntries: snapshot.data!
                      .map(
                        (e) => DropdownMenuEntry<Curso>(
                          label: e.nombre,
                          value: e,
                        ),
                      )
                      .toList(),
                ),
              );
            } else if (snapshot.data != null && snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                    'No se encontraron cursos asociados al profesor'),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              return const Text('Ocurrio un error');
            }
          },
        ),
        FutureBuilder(
          future: servicio.listarAlumnosPorCurso(cursoSeleccionado),
          builder: (context, snapshot) {
            if (cursoSeleccionado == null) {
              return const SizedBox();
            } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height - 250,
                alignment: Alignment.topCenter,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Nota')),
                  ],
                  rows: snapshot.data!.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text(e.nombre)),
                        DataCell(Text(e.correo)),
                        DataCell(TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LimitRange(0, 10),
                          ],
                          onChanged: (value) {
                            if (notas.any(
                                (element) => element.keys.first.uid == e.uid)) {
                              setState(() {
                                notas.removeWhere(
                                  (element) => element.keys.first.uid == e.uid,
                                );
                                notas.add({
                                  e: Nota(
                                    DateTime.now(),
                                    int.parse(value),
                                  )
                                });
                              });
                            } else {
                              setState(() {
                                notas.add({
                                  e: Nota(
                                    DateTime.now(),
                                    int.parse(value),
                                  )
                                });
                              });
                            }
                          },
                        ))
                      ],
                    );
                  }).toList(),
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
        ),
        Builder(
          builder: (context) {
            if (cursoSeleccionado == null) {
              return const SizedBox();
            } else {
              return Container(
                margin: const EdgeInsets.all(20),
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue),
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                      textStyle:
                          MaterialStatePropertyAll(TextStyle(fontSize: 24))),
                  onPressed: () {
                    if (cursoSeleccionado != null && notas.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return FutureBuilder(
                            future: cargarListaNotas(cursoSeleccionado!, notas),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                String message = '';
                                if (snapshot.data!) {
                                  message =
                                      'Exito en la carga de notas para el curso';
                                } else {
                                  message =
                                      'Ocurrio un error en la carga de notas';
                                }
                                return AlertDialog(
                                  title: const Text('Resultado carga notas'),
                                  content: Text(message),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                );
                              } else {
                                return Container(
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
                  child: const Text('Agregar notas'),
                ),
              );
            }
          },
        )
      ],
    );
  }
}

class LimitRange extends TextInputFormatter {
  LimitRange(
    this.minRange,
    this.maxRange,
  ) : assert(
          minRange < maxRange,
        );

  final int minRange;
  final int maxRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var value = int.tryParse(newValue.text);
    if (value == null || value < minRange) {
      // print('value print in between 1 - 20');
      return TextEditingValue(text: minRange.toString());
    } else if (value > maxRange) {
      // print('not more 20');
      return TextEditingValue(text: maxRange.toString());
    }
    return newValue;
  }
}
