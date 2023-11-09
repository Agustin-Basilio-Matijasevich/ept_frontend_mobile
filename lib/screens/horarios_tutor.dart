import 'package:ept_frontend/widgets/expanded_panel_list/curso_panel_list.dart';
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
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth,
            height: 100,
            alignment: Alignment.center,
            child: FutureBuilder(
              future: servicio.getHijos(usuario!),
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  return DropdownButton(
                    onChanged: (value) {
                      setState(() {
                        estudianteSeleccionado = value;
                      });
                    },
                    hint: (estudianteSeleccionado == null)
                        ? const Text('Seleccione un hijo')
                        : Text(estudianteSeleccionado!.nombre),
                    items: snapshot.data!
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.nombre),
                          ),
                        )
                        .toList(),
                  );
                } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                  return const Text('No se encontraron hijos para mostrar');
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  estudianteSeleccionado = null;
                  return const CircularProgressIndicator();
                } else {
                  return const Text('Ocurrio un error');
                }
              },
            ),
          ),
        ),
        SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) => FutureBuilder(
              future: servicio.getCursosPorUsuario(estudianteSeleccionado),
              builder: (context, snapshot) {
                if (estudianteSeleccionado == null) {
                  return const SizedBox();
                }
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  return CursosExpansionPanelList(
                    cursos: snapshot.data!,
                    constraints: constraints,
                  );
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
        ),
      ],
    );
  }
}
