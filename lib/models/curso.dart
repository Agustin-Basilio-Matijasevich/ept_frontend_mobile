import 'package:flutter/material.dart';

enum DiaSemana {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes,
}

class Curso {
  final String nombre;
  final DiaSemana dia;
  final TimeOfDay horainicio;
  final TimeOfDay horafin;
  final String aula;

  Curso(this.nombre, this.dia, this.horainicio, this.horafin, this.aula);

  static Curso? fromJson(Map<String, dynamic> json) {
    try {
      final String nombre = json['nombre'];
      final DiaSemana dia = DiaSemana.values
          .firstWhere((element) => element.toString() == json['dia']);
      final TimeOfDay horainicio = TimeOfDay(
          hour: int.parse(json['horainicio'].toString()),
          minute: int.parse(json['minutoinicio'].toString()));
      final TimeOfDay horafin = TimeOfDay(
          hour: int.parse(json['horafin'].toString()),
          minute: int.parse(json['minutofin'].toString()));
      final String aula = json['aula'];
      return Curso(nombre, dia, horainicio, horafin, aula);
    } catch (e) {
      print("Error Parseando JSON a Curso. Exeption: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dia': dia.toString(),
      'horainicio': horainicio.hour,
      'minutoinicio': horainicio.minute,
      'horafin': horafin.hour,
      'minutofin': horafin.minute,
      'aula': aula,
    };
  }

  @override
  String toString() {
    return 'Curso: $nombre, Dia: $dia, Hora de Inicio: $horainicio, Hora de Finalizacion: $horafin, Aula: $aula';
  }
}
