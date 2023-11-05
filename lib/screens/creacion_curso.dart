// ignore_for_file: unnecessary_this

import 'package:ept_frontend/main.dart';
import 'package:ept_frontend/models/curso.dart';
// import 'package:ept_frontend/models/usuario.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../services/businessdata.dart';

class CreacionCurso extends StatelessWidget {
  const CreacionCurso({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creación de Curso'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: const Formulario(),
        ),
      ),
    );
  }
}

class Formulario extends StatefulWidget {
  const Formulario({super.key});

  @override
  State<Formulario> createState() => FormularioState();
}

class FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();

  bool esVisible = false;
  String? nombre = '';
  String? aula = '';
  DiaSemana? diaSemana;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;

  String? emailValidator(String? email) {
    // validacion email
    if (email == null || email.isEmpty) {
      return 'El email no puede estar vacío';
    }
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (!emailValid) {
      return 'Email invalido';
    }
    return null;
  }

  final nombreController = TextEditingController();
  final aulaController = TextEditingController();
  final horaInicioController = TextEditingController();
  final horaFinController = TextEditingController();
  final diaController = TextEditingController();

  final AuthService auth = AuthService();
  final BusinessData business = BusinessData();

  Widget _gap() => const SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nombre
          TextFormField(
            controller: nombreController,
            validator: (String? value) {
              if (value != null) {
                setState(() {
                  nombre = value;
                });
              } else {
                return 'El nombre no puede estar vacío';
              }
              return null;
            },
            onChanged: (val) {
              setState(() => nombre = val);
            },
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ingrese un nombre',
              prefixIcon: Icon(Icons.edit_location_alt_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          _gap(),
          // Aula
          TextFormField(
            controller: aulaController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? value) {
              final formatoAula = RegExp(r'^[A-Z]+\-[0-9]$');
              if (value == null) {
                return 'El nombre del aula no puede ser nulo';
              } else if (value.isEmpty) {
                return 'El nombre del aula no puede ser vacío';
              } else if (!formatoAula.hasMatch(value)) {
                return 'El nombre del aula no cumple con el formato establecido';
              } else {
                return null;
              }
            },
            onChanged: (value) {
              setState(() => aula = value);
            },
            decoration: const InputDecoration(
              labelText: 'Aula',
              hintText: 'Ingrese un aula',
              prefixIcon: Icon(Icons.room),
              border: OutlineInputBorder(),
            ),
          ),
          _gap(),
          // Dia de cursado
          DropdownMenu<DiaSemana>(
            width: MediaQuery.of(context).size.width / 2,
            controller: diaController,
            onSelected: (DiaSemana? value) {
              setState(() {
                this.diaSemana = value;
              });
            },
            dropdownMenuEntries: DiaSemana.values
                .map<DropdownMenuEntry<DiaSemana>>((DiaSemana value) {
              String label = '';
              switch (value) {
                case DiaSemana.lunes:
                  label = 'Lunes';
                  break;
                case DiaSemana.martes:
                  label = 'Martes';
                  break;
                case DiaSemana.miercoles:
                  label = 'Miercoles';
                  break;
                case DiaSemana.jueves:
                  label = 'Jueves';
                  break;
                case DiaSemana.viernes:
                  label = 'Viernes';
                  break;
              }
              return DropdownMenuEntry<DiaSemana>(
                value: value,
                label: label,
              );
            }).toList(),
            hintText: 'Dia de la semana',
          ),
          _gap(),
          // Horario Inicio
          TextFormField(
            controller: horaInicioController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Hora de inicio',
              hintText: 'Pulse para elegir un horario',
              prefixIcon: Icon(Icons.timer),
              border: OutlineInputBorder(),
            ),
            onTap: () async {
              TimeOfDay? timePicked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                initialEntryMode: TimePickerEntryMode.input,
              );
              horaInicioController.text =
                  '${timePicked?.hour}:${timePicked?.minute.toString().padLeft(2, '0')}';
              setState(() => horaInicio = timePicked);
            },
          ),
          _gap(),
          // Horario Fin
          TextFormField(
            controller: horaFinController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Hora de fin',
              hintText: 'Pulse para elegir un horario',
              prefixIcon: Icon(Icons.timer),
              border: OutlineInputBorder(),
            ),
            onTap: () async {
              TimeOfDay? timePicked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                initialEntryMode: TimePickerEntryMode.input,
              );
              horaFinController.text =
                  '${timePicked?.hour}:${timePicked?.minute.toString().padLeft(2, '0')}';
              setState(() => horaFin = timePicked);
            },
          ),
          _gap(),
          // Enviar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Crear Curso',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final bool formSent = await business.crearCurso(Curso(
                    this.nombre!,
                    this.diaSemana!,
                    this.horaInicio!,
                    this.horaFin!,
                    this.aula!,
                  ));
                  if (formSent) {
                    showDialog(
                      context: navigatorKey.currentContext!,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Respuesta Creación Curso"),
                          content: const Text("Curso creado con exito!"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Aceptar"),
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {
                      nombre = '';
                      diaSemana = null;
                      horaInicio = null;
                      horaFin = null;
                      aula = '';
                      nombreController.text = '';
                      diaController.text = '';
                      horaInicioController.text = '';
                      horaFinController.text = '';
                      aulaController.text = '';
                    });
                  } else {
                    showDialog(
                      context: navigatorKey.currentContext!,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Respuesta Creación Curso"),
                          content: const Text(
                              "Ocurrió un error y no se pudo crear el curso"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Aceptar"))
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
