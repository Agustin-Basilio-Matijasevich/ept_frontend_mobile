import 'package:ept_frontend/models/recordatorio.dart';
import 'package:ept_frontend/screens/recordatorios/agregar_recordatorio.dart';
import 'package:ept_frontend/services/recordatorios_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/curso.dart';
import '../../models/usuario.dart';
import '../util_functions.dart';

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
    final formKey = GlobalKey<FormState>();

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
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(
                        e.entries.first.value.descripcion,
                        softWrap: true,
                      ),
                      isThreeLine: true,

                      // Botones
                      trailing: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * (5 / 10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8, left: 8),
                              child: Text(
                                '${e.entries.first.value.fechaRecordar.year}'
                                '/${e.entries.first.value.fechaRecordar.month}/'
                                '${e.entries.first.value.fechaRecordar.day}'
                                '\n'
                                '${e.entries.first.value.fechaRecordar.hour.toString().padLeft(2, '0')}'
                                ':${e.entries.first.value.fechaRecordar.minute.toString().padLeft(2, '0')}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    final tituloController =
                                        TextEditingController(
                                      text: e.entries.first.value.titulo,
                                    );
                                    final descripcionController =
                                        TextEditingController(
                                      text: e.entries.first.value.descripcion,
                                    );
                                    final fechaRecordarController =
                                        TextEditingController(
                                      text: e.entries.first.value.fechaRecordar
                                          .toString()
                                          .substring(0, 16),
                                    );

                                    DateTime? fechaRecordar =
                                        e.entries.first.value.fechaRecordar;
                                    return AlertDialog(
                                      title:
                                          const Text('Modificar Recordatorio'),
                                      content: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Form(
                                          key: formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Titulo
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    label: Text('Titulo'),
                                                  ),
                                                  controller: tituloController,
                                                ),
                                              ),
                                              // Descripcion
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    label: Text('Descripcion'),
                                                  ),
                                                  controller:
                                                      descripcionController,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 16, 8, 8),
                                                child: TextFormField(
                                                  controller:
                                                      fechaRecordarController,
                                                  readOnly: true,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Hora a Recordar',
                                                    hintText:
                                                        'Pulse para elegir un horario',
                                                    prefixIcon:
                                                        Icon(Icons.timer),
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  validator: (value) => (value ==
                                                              null ||
                                                          value.trim() == '' ||
                                                          DateTime.tryParse(
                                                                  value) ==
                                                              null)
                                                      ? 'Ingrese una fecha y hora validas'
                                                      : null,
                                                  onTap: () async {
                                                    DateTime? datePicked =
                                                        await UtilFunctions
                                                            .showDateTimePicker(
                                                                context);

                                                    if (datePicked != null) {
                                                      fechaRecordarController
                                                              .text =
                                                          datePicked
                                                              .toString()
                                                              .substring(0, 16);
                                                      setState(() {
                                                        fechaRecordar =
                                                            datePicked;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              recordatoriosService
                                                  .modificaRecordatorio(
                                                usuario,
                                                e.entries.first.key,
                                                Recordatorio(
                                                  tituloController.text,
                                                  descripcionController.text,
                                                  e.entries.first.value
                                                      .fechaCreacion,
                                                  fechaRecordar!,
                                                ),
                                              )
                                                  .then(
                                                (value) {
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            }
                                          },
                                          child: const Text('Modificar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancelar'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Eliminar Recordatorio'),
                              content: const Text(
                                  '¿Esta seguro que quiere eliminar este recordatorio?'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    recordatoriosService
                                        .borraRecordatorio(
                                            usuario, e.entries.first.key)
                                        .then(
                                      (value) {
                                        setState(
                                          () {},
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
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
