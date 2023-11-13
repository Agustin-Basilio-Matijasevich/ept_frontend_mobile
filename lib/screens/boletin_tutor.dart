// import 'package:ept_frontend/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../models/curso.dart';
import '../models/usuario.dart';
import '../services/businessdata.dart';
import '../widgets/expanded_panel_list/notas_panel_list.dart';

class BoletinTutor extends StatelessWidget {
  const BoletinTutor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boletin'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
  Usuario? usuarioSeleccionado;
  final servicio = BusinessData();
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    final servicio = BusinessData();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Controles
          LayoutBuilder(
            builder: (context, constraints) => FutureBuilder(
              future: servicio.getHijos(usuario!),
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: DropdownButton<Usuario>(
                      // Si no hay un usuario seleccionado, muestra hint,
                      // Sino, muestra el nombre del usuario seleccionado.
                      hint: (usuarioSeleccionado == null)
                          ? const Text('Seleccione un usuario')
                          : Text(usuarioSeleccionado!.nombre),
                      // Cuando se lanza el evento, si se selecciona el mismo
                      // usuario, no se cambia el estado. (No se refresca)
                      onChanged: (value) {
                        if (usuarioSeleccionado == null ||
                            usuarioSeleccionado!.uid != value!.uid) {
                          setState(() {
                            usuarioSeleccionado = value;
                          });
                        }
                      },
                      items: snapshot.data!.map(
                        (e) {
                          return DropdownMenuItem<Usuario>(
                            value: e,
                            child: Text(e.nombre),
                          );
                        },
                      ).toList(),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  return const Icon(Icons.do_not_disturb_alt);
                }
              },
            ),
          ),
          // Lista de materias que al presionar muestran las notas
          LayoutBuilder(
            builder: (context, constraints) => FutureBuilder(
              future: servicio.getPromedioPorCurso(usuarioSeleccionado, 2023),
              builder: (context, snapshot) {
                if (usuarioSeleccionado == null) {
                  return const SizedBox();
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return NotasExpansionPanelList(
                      notas: snapshot.data!, constraints: constraints);
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                  return const Text('No se encontraron datos para mostrar');
                } else {
                  return const Text('Ocurrio un error');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
