import 'package:ept_frontend/models/recordatorio.dart';
import 'package:ept_frontend/screens/recordatorios/agregar_recordatorio.dart';
import 'package:ept_frontend/services/recordatorios_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/curso.dart';
import '../../models/usuario.dart';

class RecordatoriosPanelList extends StatefulWidget {
  const RecordatoriosPanelList({
    super.key,
    required this.constraints,
  });

  final BoxConstraints constraints;
  @override
  State<RecordatoriosPanelList> createState() => _RecordatoriosPanelListState();
}

class _RecordatoriosPanelListState extends State<RecordatoriosPanelList> {
  Map<String, Recordatorio>? objetoSeleccionado;

  RecordatoriosService recordatoriosService = RecordatoriosService();

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario>(context);
    final _formKey = GlobalKey<FormState>();
    return FutureBuilder(
      future: recordatoriosService.getRecordatorios(usuario),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data!.length);
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView(
            children: snapshot.data!
                .map(
                  (e) => Card(
                    child: ListTile(
                      title: Text(
                        e.entries.first.value.titulo,
                        softWrap: true,
                      ),
                      subtitle: Text(
                        e.entries.first.value.descripcion,
                        softWrap: true,
                      ),
                      isThreeLine: true,

                      // Botones
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Modificar Recordatorio'),
                                content: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.isEmpty) {
          return const SizedBox();
        } else {
          return const Center(child: Text('Ocurrio un error :('));
        }
      },
    );
  }
}
