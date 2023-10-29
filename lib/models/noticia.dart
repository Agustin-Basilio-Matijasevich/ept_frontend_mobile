// ignore_for_file: avoid_print

class Noticia {
  final String titulo;
  final String contenido;
  final String autor;
  final String? imagen;

  Noticia(this.titulo, this.contenido, this.autor, this.imagen);

  static Noticia? fromJson(Map<String, dynamic> json) {
    try {
      final String titulo = json['titulo'];
      final String contenido = json['contenido'];
      final String autor = json['autor'];
      String? imagen = json['imagen'];

      if (imagen == '') {
        imagen = null;
      }

      return Noticia(titulo, contenido, autor, imagen);
    } catch (e) {
      print("Error Parseando JSON a Noticia. Exeption: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    String newimagen;

    if (imagen == null) {
      newimagen = '';
    } else {
      newimagen = imagen!;
    }

    return {
      'titulo': titulo,
      'contenido': contenido,
      'autor': autor,
      'imagen': newimagen,
    };
  }

  @override
  String toString() {
    return 'Autor: $autor, Titulo: $titulo, Contenido: $contenido';
  }
}
