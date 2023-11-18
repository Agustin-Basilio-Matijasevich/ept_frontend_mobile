import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recordatorio.dart';
import '../../models/usuario.dart';
import '../../services/recordatorios_service.dart';

class AgregarRecordatorio extends StatelessWidget {
  const AgregarRecordatorio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: AgregarRecordatorioForm(),
      ),
    );
  }
}

class AgregarRecordatorioForm extends StatefulWidget {
  const AgregarRecordatorioForm({super.key});

  @override
  State<AgregarRecordatorioForm> createState() =>
      _AgregarRecordatorioFormState();
}

class _AgregarRecordatorioFormState extends State<AgregarRecordatorioForm> {
  final formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final subtituloController = TextEditingController();
  final horaInicioController = TextEditingController();
  final horaFinController = TextEditingController();

  DateTime? horaInicio;
  DateTime? horaFin;

  RecordatoriosService recordatoriosService = RecordatoriosService();

  static Future<DateTime?> showDateTimePicker(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    ).then(
      (selectedDate) {
        print(selectedDate);
        if (selectedDate != null) {
          return showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 0, minute: 0),
            initialEntryMode: TimePickerEntryMode.input,
          ).then(
            (selectedTime) {
              print(selectedTime);
              if (selectedTime != null) {
                DateTime returnDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                print(returnDateTime.toString());
                return returnDateTime;
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario>(context);

    return LayoutBuilder(
      builder: (context, constraints) => Form(
        key: formKey,
        child: Container(
          alignment: Alignment.center,
          width: constraints.maxWidth * (8 / 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titulo
              Padding(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Titulo'),
                  ),
                  controller: tituloController,
                ),
              ),
              // Subtitulo
              Padding(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Subtitulo'),
                  ),
                  maxLength: 255,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  controller: subtituloController,
                ),
              ),
              // Hora Inicio
              Padding(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                  controller: horaInicioController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Hora de inicio',
                    hintText: 'Pulse para elegir un horario',
                    prefixIcon: Icon(Icons.timer),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null ||
                          value.trim() == '' ||
                          DateTime.tryParse(value) == null)
                      ? 'Ingrese una fecha y hora validas'
                      : null,
                  onTap: () async {
                    DateTime? datePicked = await showDateTimePicker(context);

                    horaInicioController.text = (datePicked != null)
                        ? datePicked.toString().substring(0, 16)
                        : horaInicioController.text;
                    setState(() {
                      horaInicio = datePicked;
                    });
                  },
                ),
              ),
              // Hora Fin
              Padding(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                  controller: horaFinController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Hora de inicio',
                    hintText: 'Pulse para elegir un horario',
                    prefixIcon: Icon(Icons.timer),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null ||
                          value.trim() == '' ||
                          DateTime.tryParse(value) == null)
                      ? 'Ingrese una fecha y hora validas'
                      : null,
                  onTap: () async {
                    DateTime? datePicked = await showDateTimePicker(context);

                    horaFinController.text = (datePicked != null)
                        ? datePicked.toString().substring(0, 16)
                        : horaFinController.text;
                    setState(() {
                      horaFin = datePicked;
                    });
                  },
                ),
              ),
              // Boton Agregar
              // Se esconde si esta abierto el ingreso de texto
              (WidgetsBinding.instance.window.viewInsets.bottom == 0.0)
                  ? ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return FutureBuilder(
                                future: recordatoriosService.grabaRecordatorio(
                                  usuario,
                                  Recordatorio(
                                    tituloController.text,
                                    subtituloController.text,
                                    horaInicio!,
                                    horaFin!,
                                  ),
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data!) {
                                    Navigator.of(context).pop();
                                    return const SizedBox();
                                  } else if (snapshot.hasData &&
                                      !snapshot.data!) {
                                    return AlertDialog(
                                      title: const Text('Resultado Creacion'),
                                      content: const Text(
                                          'Ocurrio un error en la creacion del recordatorio'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Aceptar'),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              );
                            },
                          ).then((response) {
                            if (response == null || response == false) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context)
                                ..pop()
                                ..pop();
                            }
                          });
                        }
                      },
                      child: const Text('Agregar'),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
