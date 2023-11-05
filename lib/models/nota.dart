// ignore_for_file: avoid_print

class Nota {
  final DateTime fecha;
  final int nota;

  Nota(this.fecha, this.nota);

  static Nota? fromJson(Map<String, dynamic> json) {
    try {
      final DateTime fecha = DateTime.parse(json['fecha'].toString());
      final int nota = int.parse(json['nota'].toString());
      return Nota(fecha, nota);
    } catch (e) {
      print("Error parseando JSON a Nota. Exeption: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {'fecha': fecha.toIso8601String(), 'nota': nota.toString()};
  }

  @override
  String toString() {
    return 'Fecha: $fecha, Nota: $nota';
  }
}
