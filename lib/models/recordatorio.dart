

class Recordatorio {
  final String titulo;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaRecordar;

  Recordatorio(this.titulo,this.descripcion,this.fechaCreacion,this.fechaRecordar);

  static Recordatorio? fromJson(Map<String,dynamic> json) {
    try {
      final String titulo = json['titulo'];
      final String descripcion = json['descripcion'];
      final DateTime fechaCreacion = DateTime.parse(json['fechaCreacion'].toString());
      final DateTime fechaRecordar = DateTime.parse(json['fechaRecordar'].toString());
      return Recordatorio(titulo, descripcion, fechaCreacion, fechaRecordar);
    } catch (e) {
      print("Error Parseando JSON a Recordatorio. Exeption: $e");
      return null;
    }
  }

  Map<String,dynamic> toJson() {
    return {
      'titulo' : titulo,
      'descripcion' : descripcion,
      'fechaCreacion' : fechaCreacion,
      'fechaRecordar' : fechaRecordar,
    };
  }

  @override
  String toString() {
    return 'Titulo: $titulo, Descripcion: $descripcion, Fecha de Creacion: $fechaCreacion, Fecha a Recordar: $fechaRecordar';
  }

}