import 'package:ept_frontend/widgets/expanded_panel_list/curso_panel_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curso.dart';
import '../models/usuario.dart';
import '../services/businessdata.dart';

/// Esta clase esta destinada a mostrar los horarios de los estudiantes
/// y no docentes.
///
/// Si desea mostrar el listado de horarios para los hijos de un tutor,
/// debe utilizar la clase HorariosTutor.
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
              return CursosExpansionPanelList(
                cursos: snapshot.data!,
                constraints: constraints,
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
