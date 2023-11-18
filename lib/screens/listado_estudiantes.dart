import 'package:ept_frontend/services/businessdata.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/curso.dart';
import '../models/usuario.dart';
//import '../services/pdfgenerator.dart';
// import 'package:pdf/widgets.dart';

// Para mostrar estudiantes que tiene un profesor por cada materia
class ListadoEstudiantes extends StatelessWidget {
  const ListadoEstudiantes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de estudiantes'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.topCenter,
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
  Curso? cursoSeleccionado;
  final servicio = BusinessData();

  List<Usuario>? dataset;
  ConnectionState? datasetState;

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(30),
            width: constraints.maxWidth,
            // height: 50,
            child: FutureBuilder(
              future: servicio.getCursosPorUsuario(usuario!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return DropdownButton(
                    hint: (cursoSeleccionado == null)
                        ? const Text('Seleccione un curso')
                        : Text(cursoSeleccionado!.nombre),
                    onChanged: (value) {
                      if ((cursoSeleccionado != null && value != null) &&
                          cursoSeleccionado!.nombre != value.nombre) {
                        setState(() {
                          cursoSeleccionado = value;
                        });
                      }
                    },
                    items: snapshot.data!
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.nombre),
                          ),
                        )
                        .toList(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Text('Usted no tiene cursos asociados');
                } else {
                  return const Text('Ocurrio un error');
                }
              },
            ),
          ),
        ),
        SingleChildScrollView(
          child: FutureBuilder(
            future: servicio.listarAlumnosPorCurso(cursoSeleccionado),
            builder: (context, snapshot) {
              datasetState = snapshot.connectionState;
              if (cursoSeleccionado == null) {
                return const SizedBox();
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                dataset = snapshot.data;
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre Completo')),
                    DataColumn(
                      label: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text('Email'),
                      ),
                    ),
                  ],
                  rows: snapshot.data!.map(
                    (e) {
                      return DataRow(
                        cells: [
                          DataCell(Text(e.nombre)),
                          DataCell(
                            Text(e.correo),
                            onLongPress: () {
                              Clipboard.setData(ClipboardData(text: e.correo))
                                  .then(
                                (v) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Correo copiado al portapapeles"),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ).toList(),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Text('No se encontraron alumnos para el curso');
              } else {
                return const Text('Ocurrio un error');
              }
            },
          ),
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
