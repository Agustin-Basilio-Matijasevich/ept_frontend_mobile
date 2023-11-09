// import 'package:ept_frontend/models/nota.dart';
import 'package:ept_frontend/widgets/expanded_panel_list/notas_panel_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../models/curso.dart';
import '../models/usuario.dart';
import '../services/businessdata.dart';

class BoletinEstudiante extends StatelessWidget {
  const BoletinEstudiante({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boletin'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: ListaBoletin(),
      ),
    );
  }
}

class ListaBoletin extends StatefulWidget {
  ListaBoletin({super.key});
  final servicio = BusinessData();

  @override
  State<ListaBoletin> createState() => _ListaBoletinState();
}

class _ListaBoletinState extends State<ListaBoletin> {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) => FutureBuilder(
          future: widget.servicio.getPromedioPorCurso(usuario!, 2023),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return NotasExpansionPanelList(
                notas: snapshot.data!,
                constraints: constraints,
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
      ),
    );
  }
}
