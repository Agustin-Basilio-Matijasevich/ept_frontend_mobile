import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curso.dart';
import '../models/usuario.dart';
import '../services/businessdata.dart';

// PARA ESTUDIANTES
class Horarios extends StatelessWidget {
  const Horarios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: const ListaHorarios(),
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
  final servicio = BusinessData();

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    return FutureBuilder(
      future: servicio.getCursosPorUsuario(usuario),
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

class ListaHorarios extends StatefulWidget {
  const ListaHorarios({super.key});

  @override
  State<ListaHorarios> createState() => _ListaHorariosState();
}

class _ListaHorariosState extends State<ListaHorarios>
    with TickerProviderStateMixin {
  final servicio = BusinessData();

  Curso? cursoSeleccionado;

  Widget botonCurso(Curso curso, bool selected) {
    return TextButton.icon(
      onPressed: () {
        setState(() {
          if (!selected) {
            cursoSeleccionado = curso;
          } else {
            cursoSeleccionado = null;
          }
        });
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.blue),
        foregroundColor: MaterialStatePropertyAll(Colors.white),
      ),
      icon: selected
          ? const Icon(Icons.arrow_drop_down)
          : const Icon(Icons.arrow_drop_up),
      label: Text(curso.nombre),
    );
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat();

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
        builder: (context, constraints) => FutureBuilder(
          future: servicio.getCursosPorUsuario(usuario),
          builder: (context, snapshot) {
            // Si el servicio contesto y tiene cursos
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    if (isExpanded) {
                      cursoSeleccionado = null;
                    } else {
                      cursoSeleccionado = snapshot.data![index];
                    }
                  });
                },
                children: snapshot.data!
                    .map(
                      (e) => ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(e.nombre),
                            selected: isExpanded,
                            tileColor: Colors.blue,
                            // selectedTileColor: Colors.blue,
                            textColor: Colors.white,
                          );
                        },
                        isExpanded: (cursoSeleccionado != null &&
                            cursoSeleccionado!.nombre == e.nombre),
                        canTapOnHeader: true,
                        body: Container(
                          width: constraints.maxWidth,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 10,
                              top: 10,
                            ),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Nombre: ${e.nombre} \n'
                              'Aula: ${e.aula} \n'
                              'Dia: ${e.dia.name[0].toUpperCase() + e.dia.name.substring(1)} \n'
                              'Hora Inicio: ${e.horainicio.hour.toString().padLeft(2, '0')}:${e.horafin.minute.toString().padLeft(2, '0')} \n'
                              'Hora Fin: ${e.horafin.hour.toString().padLeft(2, '0')}:${e.horafin.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            // Si el servicio contesto y no tiene cursos
            else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Text("No se encontraron cursos para mostrar");
            }
            // Si el servicio no contesto
            else if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator.adaptive();
            }
            // Sino muestra error
            else {
              return const Text("Ocurrio un error");
            }
          },
        ),
      ),
    );
  }
}

// Text(
// '    Nombre: ${e.nombre} \n'
// '    Aula: ${e.aula} \n'
// '    Dia: ${e.dia.name[0].toUpperCase() + e.dia.name.substring(1)} \n'
// '    Hora Inicio: ${e.horainicio.hour.toString().padLeft(2, '0')}:${e.horafin.minute.toString().padLeft(2, '0')} \n'
// '    Hora Fin: ${e.horafin.hour.toString().padLeft(2, '0')}:${e.horafin.minute.toString().padLeft(2, '0')}',
// style: const TextStyle(
// fontSize: 18,
// ),
// ),