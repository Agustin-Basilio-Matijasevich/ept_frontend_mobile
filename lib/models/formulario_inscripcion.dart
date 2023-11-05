// ignore_for_file: non_constant_identifier_names, avoid_print

enum NivelEducativo {
  inicial,
  primario,
  secundario,
}

class FormInscripcion {
  final String apellido_alumno;
  final String apellido_tutor;
  final String nombre_alumno;
  final String nombre_tutor;
  final String email_tutor;
  final int anio_lectivo;
  final int dni_alumno;
  final int dni_tutor;
  final DateTime fecha_nacimiento_alumno;
  final NivelEducativo nivel;

  static FormInscripcion? fromJson(Map<String, dynamic> json) {
    try {
      final String apellido_alumno = json['apellido_alumno'];
      final String apellido_tutor = json['apellido_tutor'];
      final String nombre_alumno = json['nombre_alumno'];
      final String nombre_tutor = json['nombre_tutor'];
      final String email_tutor = json['email_tutor'];
      final int anio_lectivo = int.parse(json['año_lectivo'].toString());
      final int dni_alumno = int.parse(json['dni_alumno'].toString());
      final int dni_tutor = int.parse(json['dni_tutor'].toString());
      final DateTime fecha_nacimiento_alumno =
          DateTime.parse(json['fecha_nacimiento_alumno'].toString());
      final NivelEducativo nivel = NivelEducativo.values
          .firstWhere((element) => element.toString() == json['nivel']);

      return FormInscripcion(
          apellido_alumno,
          apellido_tutor,
          nombre_alumno,
          nombre_tutor,
          email_tutor,
          anio_lectivo,
          dni_alumno,
          dni_tutor,
          fecha_nacimiento_alumno,
          nivel);
    } catch (e) {
      print("Error parseando JSON a FormInscription. Exeption: $e");
      return null;
    }
  }

  FormInscripcion(
      this.apellido_alumno,
      this.apellido_tutor,
      this.nombre_alumno,
      this.nombre_tutor,
      this.email_tutor,
      this.anio_lectivo,
      this.dni_alumno,
      this.dni_tutor,
      this.fecha_nacimiento_alumno,
      this.nivel);
}
