import 'dart:io';
import 'package:ept_frontend/models/formulario_inscripcion.dart';
import 'package:ept_frontend/models/nota.dart';
import 'package:ept_frontend/models/pago.dart';
import 'package:ept_frontend/models/usuario.dart';
import 'package:firebase_for_all/firebase_for_all.dart';
import 'package:ept_frontend/models/curso.dart';
import 'package:ept_frontend/models/noticia.dart';

class BusinessData {
  final FirestoreItem _db =
      FirestoreForAll.instance; //Inicializo instancia de firestore
  final StorageRef _cloud = FirebaseStorageForAll.instance
      .ref(); //Inicializo la instancia de Firebase Cloud

  //Para mi (Usa si te sirve)
  Future<UserRoles?> getUserRol(String uid) async {
    try {
      Map<String, dynamic>? usuario = await _db
          .collection("usuarios")
          .doc(uid)
          .get()
          .then((value) => value.map);

      if (usuario == null) {
        throw Exception("Documento Vacio");
      }

      return UserRoles.values
          .firstWhere((element) => element.toString() == usuario['rol']);
    } catch (e) {
      print("Error obteniendo rol de usuario. Exeption: $e");
      return null;
    }
  }

  Future<bool> esCursoyUsuario(String uid, String curso) async {
    try {
      await _db
          .collection("usuarios")
          .doc(uid)
          .collection("cursos")
          .doc(curso)
          .get();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Curso?> getCurso(String nombre) async {
    DocRef documento = _db.collection("cursos").doc(nombre);
    Map<String, dynamic>? json;

    try {
      json = await documento.get().then((value) => value.map);
      if (json == null) {
        throw Exception('JSON NULO');
      }
    } catch (e) {
      print("No se encontro el curso. Exeption: $e");
      return null;
    }

    return Curso.fromJson(json);
  }

  double calcularDeuda(Pago? pago) {
    if (pago == null) {
      return 15000;
    }

    double pagofinal = 0;
    const double cuota = 10000;
    final DateTime fechapago = pago.fecha;
    final DateTime fechaact = DateTime.now();

    if (fechapago.month == fechaact.month) {
      return 0;
    } else {
      int mesesatraso = (fechaact.month - fechapago.month) - 1;

      for (int i = 0; i < mesesatraso; i++) {
        pagofinal += cuota * 1.2;
      }

      if (fechaact.day > 15) {
        pagofinal += cuota * 1.1;
      } else {
        pagofinal += cuota;
      }

      return pagofinal;
    }
  }

  Future<Pago?> getUltPago(String uid) async {
    try {
      List<DocumentSnapshotForAll<Map<String, Object?>>> documentos = await _db
          .collection('usuarios')
          .doc(uid)
          .collection('pagos')
          .orderBy('fecha', descending: true)
          .limit(1)
          .get()
          .then((value) => value.docs);

      Map<String, dynamic>? pago = documentos.first.map;

      if (pago == null) {
        throw Exception('No tiene Pagos Realizados.');
      }

      return Pago.fromJson(pago);
    } catch (e) {
      print("Error al recuperar ultimo Pago. Exeption: $e");
      return null;
    }
  }

  Future<bool> esDeudor(String uid) async {
    Pago? pago = await getUltPago(uid);

    if (pago != null) {
      if (pago.fecha.month == DateTime.now().month) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<bool> esHijo(String padre, String hijo) async {
    try {
      await _db
          .collection("usuarios")
          .doc(padre)
          .collection("hijos")
          .doc(hijo)
          .get();
      await _db
          .collection("usuarios")
          .doc(hijo)
          .collection("padres")
          .doc(padre)
          .get();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Nota>> getNotas(String usuario, String curso) async {
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;
    List<Nota> notas = [];

    try {
      documentos = await _db
          .collection('usuarios')
          .doc(usuario)
          .collection('cursos')
          .doc(curso)
          .collection('notas')
          .orderBy('fecha', descending: false)
          .get()
          .then((value) => value.docs);
    } catch (e) {
      print("No se pudieron obtener las Notas de la DB. Exeption: $e");
      return [];
    }

    for (var element in documentos) {
      Map<String, dynamic>? json = element.map;

      if (json != null) {
        Nota? nota = Nota.fromJson(json);

        if (nota != null) {
          notas.add(nota);
        }
      }
    }

    return notas;
  }

  Future<List<Nota>> getNotasFiltroAnio(
      String usuario, String curso, int anio) async {
    List<Nota> notas = await getNotas(usuario, curso);
    List<Nota> retorno = [];

    for (var element in notas) {
      if (element.fecha.year == anio) {
        retorno.add(element);
      }
    }

    return retorno;
  }

  List<int?> calcularPromedioTrimestral(List<Nota> notas, int anio) {
    DateTime inicioPrimerTrimestre = DateTime.utc(anio, 3, 20);
    DateTime finPrimerTrimestre = DateTime.utc(anio, 6, 2);
    DateTime inicioSegundoTrimestre = DateTime.utc(anio, 6, 5);
    DateTime finSegundoTrimestre = DateTime.utc(anio, 9, 1);
    DateTime inicioTercerTrimestre = DateTime.utc(anio, 9, 4);
    DateTime finTTercerTrimestre = DateTime.utc(anio, 11, 24);
    List<Nota> primerTrimestre = [];
    List<Nota> segundoTrimestre = [];
    List<Nota> tercerTrimestre = [];
    int suma;
    List<int?> retorno = [null, null, null];

    for (var nota in notas) {
      DateTime fechaNota = DateTime.utc(anio, nota.fecha.month, nota.fecha.day);
      if (fechaNota.isAfter(inicioPrimerTrimestre) &&
          fechaNota.isBefore(finPrimerTrimestre)) {
        primerTrimestre.add(nota);
      } else if (fechaNota.isAfter(inicioSegundoTrimestre) &&
          fechaNota.isBefore(finSegundoTrimestre)) {
        segundoTrimestre.add(nota);
      } else if (fechaNota.isAfter(inicioTercerTrimestre) &&
          fechaNota.isBefore(finTTercerTrimestre)) {
        tercerTrimestre.add(nota);
      }
    }

    suma = 0;

    for (var nota in primerTrimestre) {
      suma += nota.nota;
    }

    if (suma == 0) {
      retorno[0] = null;
    } else {
      retorno[0] = (suma / primerTrimestre.length).round();
    }

    suma = 0;

    for (var nota in segundoTrimestre) {
      suma += nota.nota;
    }

    if (suma == 0) {
      retorno[1] = null;
    } else {
      retorno[1] = (suma / segundoTrimestre.length).round();
    }

    suma = 0;

    for (var nota in tercerTrimestre) {
      suma += nota.nota;
    }

    if (suma == 0) {
      retorno[2] = null;
    } else {
      retorno[2] = (suma / tercerTrimestre.length).round();
    }

    return retorno;
  }

  //Para vos Master Carter Estos Metodos Jamas Fallan
  Future<bool> crearCurso(Curso curso) async {
    //Validaciones de Negocio
    if (null != await getCurso(curso.nombre)) {
      print("El curso ya existe.");
      return false;
    }

    //Tarea
    DocRef documento = _db.collection("cursos").doc(curso.nombre);

    try {
      await documento.set(curso.toJson());
    } catch (e) {
      print("Error grabando curso en la BD. Exeption: $e");
      return false;
    }

    return true;
  }

  Future<bool> pagar(Usuario usuario, Pago pago) async {
    //validaciones Negocio
    if (await getUserRol(usuario.uid) != UserRoles.estudiante ||
        !await esDeudor(usuario.uid)) {
      print("El usuario no es estudiante o no es deudor.");
      return false;
    }

    //Tarea
    ColRef coleccion =
        _db.collection("usuarios").doc(usuario.uid).collection("pagos");

    Map<String, dynamic> json = pago.toJson();

    try {
      await coleccion.add(json);
    } catch (e) {
      print("Error grabando Pago. Exeption: $e");
      return false;
    }

    return true;
  }

  Future<bool> cargarNota(Usuario usuario, Curso curso, Nota nota) async {
    if (!await esCursoyUsuario(usuario.uid, curso.nombre)) {
      print("El curso no esta vinculado al usuario");
      return false;
    }

    if (UserRoles.estudiante != await getUserRol(usuario.uid)) {
      print("El usuario debe ser estudiante");
      return false;
    }

    //Tarea
    ColRef coleccion = _db
        .collection("usuarios")
        .doc(usuario.uid)
        .collection("cursos")
        .doc(curso.nombre)
        .collection("notas");

    Map<String, dynamic> json = nota.toJson();

    try {
      await coleccion.add(json);
    } catch (e) {
      print("Error Grabando Nota. Exeption: $e");
      return false;
    }

    return true;
  }

  Future<bool> adherirCurso(Usuario usuario, Curso curso) async {
    //Validaciones Negocio
    UserRoles? rol = await getUserRol(usuario.uid);

    if (rol != UserRoles.estudiante && rol != UserRoles.docente) {
      print("El usuario debe ser docente o profesor");
      return false;
    }

    if (await getCurso(curso.nombre) == null) {
      print("El curso no existe");
      return false;
    }

    if (await esCursoyUsuario(usuario.uid, curso.nombre)) {
      print("El curso ya esta vinculado al usuario");
      return true;
    }

    //Tarea
    DocRef documento = _db
        .collection("usuarios")
        .doc(usuario.uid)
        .collection("cursos")
        .doc(curso.nombre);

    try {
      Map<String, Object?> vacio = {};
      await documento.set(vacio);
    } catch (e) {
      print("Error adiriendo curso al usuario. Exeption: $e");
      return false;
    }

    return true;
  }

  Future<bool> asignarHijo(Usuario padre, Usuario hijo) async {
    //Validaciones Negocio
    UserRoles? rolpadre = await getUserRol(padre.uid);
    UserRoles? rolhijo = await getUserRol(hijo.uid);

    if (rolpadre != UserRoles.padre || rolhijo != UserRoles.estudiante) {
      print(
          "El padre debe ser un usuario de tipo padre y el hijo debe ser estudiante");
      return false;
    }

    if (await esHijo(padre.uid, hijo.uid)) {
      print("Ya estan vinculados como padre e hijo");
      return true;
    }

    //Tarea
    DocRef documento1 = _db
        .collection("usuarios")
        .doc(padre.uid)
        .collection("hijos")
        .doc(hijo.uid);
    DocRef documento2 = _db
        .collection("usuarios")
        .doc(hijo.uid)
        .collection("padres")
        .doc(padre.uid);

    try {
      Map<String, Object?> vacio = {};
      await documento1.set(vacio);
      await documento2.set(vacio);
    } catch (e) {
      print("Error asignando hijos. Exeption: $e");
      return false;
    }

    return true;
  }

  Future<double> getDeuda(Usuario estudiante) async {
    return calcularDeuda(await getUltPago(estudiante.uid));
  }

  //Listadores
  Future<List<Curso>> getCursos() async {
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;
    List<Curso> cursos = [];

    try {
      documentos =
          await _db.collection('cursos').get().then((value) => value.docs);
    } catch (e) {
      print("No se pudieron obtener los cursos de la DB. Exeption: $e");
      return [];
    }

    for (var element in documentos) {
      Map<String, dynamic>? json = element.map;

      if (json != null) {
        Curso? curso = Curso.fromJson(json);

        if (curso != null) {
          cursos.add(curso);
        }
      }
    }

    return cursos;
  }

  //Lista todos los usuarios que deben y te los devuelve con el monto de la deuda
  Future<List<Map<Usuario, double>>> listarDeudores() async {
    List<Usuario> usuarios =
        await listarUsuariosFiltroRol(UserRoles.estudiante);
    List<Map<Usuario, double>> deudores = [];

    for (var usuario in usuarios) {
      double deuda = await getDeuda(usuario);
      if (deuda > 0) {
        deudores.add({usuario: deuda});
      }
    }

    return deudores;
  }

  // Para agregar pantalla para no docentes. El filtrado lo hago del lado del front
  Future<List<Usuario>> listarUsuarios() async {
    List<Usuario> usuarios = [];
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;

    try {
      documentos =
          await _db.collection('usuarios').get().then((value) => value.docs);
    } catch (e) {
      print("Error obteniendo usuarios de DB. Exeption: $e");
      return [];
    }

    for (var documento in documentos) {
      Map<String, dynamic>? json = documento.map;

      if (json != null) {
        json['uid'] = documento.id;
        Usuario? usuario = Usuario.fromJson(json);

        if (usuario != null) {
          usuarios.add(usuario);
        }
      }
    }

    return usuarios;
  }

  Future<List<Usuario>> listarUsuariosFiltroRol(UserRoles rol) async {
    List<Usuario> usuarios = [];
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;

    try {
      documentos = await _db
          .collection('usuarios')
          .where('rol', isEqualTo: rol.toString())
          .get()
          .then((value) => value.docs);
    } catch (e) {
      print("Error obteniendo usuarios de DB. Exeption: $e");
      return [];
    }

    for (var documento in documentos) {
      Map<String, dynamic>? json = documento.map;

      if (json != null) {
        json['uid'] = documento.id;
        Usuario? usuario = Usuario.fromJson(json);

        if (usuario != null) {
          usuarios.add(usuario);
        }
      }
    }

    return usuarios;
  }

  Future<List<Usuario>> listarAlumnosPorCurso(Curso? curso) async {
    if (curso == null) {
      return [];
    }

    List<Usuario> retorno = [];
    List<Usuario> estudiantes =
        await listarUsuariosFiltroRol(UserRoles.estudiante);

    for (var estudiante in estudiantes) {
      if (await esCursoyUsuario(estudiante.uid, curso.nombre)) {
        retorno.add(estudiante);
      }
    }

    return retorno;
  }

  Future<List<Map<Curso, List<Usuario>>>> listarAlumnosPorCursoFull() async {
    List<Map<Curso, List<Usuario>>> retorno = [];
    List<Curso> cursos = await getCursos();

    for (var curso in cursos) {
      List<Usuario> cursantes = await listarAlumnosPorCurso(curso);
      if (cursantes.isNotEmpty) {
        retorno.add({curso: cursantes});
      }
    }

    return retorno;
  }

  //Por cada curso devuelve 3 notas que son promedio de las notas del trimestre ordenadas por trimerstre, indice 0,1,2. Las notas van en formato entero
  //Si no tengo notas de un trimestre devuelvo null en la nota.
  //Las notas que se usan para calcular son las del año indicado.
  //Si no tengo ningun curso para el usuario, lista vacia.
  Future<List<Map<Curso, List<int?>>>> getPromedioPorCurso(
      Usuario? usuario, int anio) async {
    if (usuario == null) {
      return [];
    }
    List<Curso> cursos = await getCursosPorUsuario(usuario);
    List<Map<Curso, List<int?>>> retorno = [];

    for (var curso in cursos) {
      retorno.add({
        curso: calcularPromedioTrimestral(
            await getNotasFiltroAnio(usuario.uid, curso.nombre, anio), anio)
      });
    }

    return retorno;
  }

  //Pasame el padre y te devuelvo los hijos
  Future<List<Usuario>> getHijos(Usuario padre) async {
    List<Usuario> hijos = [];
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;

    try {
      documentos = await _db
          .collection('usuarios')
          .doc(padre.uid)
          .collection('hijos')
          .get()
          .then((value) => value.docs);
    } catch (e) {
      print("No tiene hijos vinculados. Exeption: $e");
      return [];
    }

    for (var documento in documentos) {
      Map<String, dynamic>? json = await _db
          .collection('usuarios')
          .doc(documento.id)
          .get()
          .then((value) => value.map);
      if (json != null) {
        json['uid'] = documento.id;
        Usuario? hijo = Usuario.fromJson(json);
        if (hijo != null) {
          hijos.add(hijo);
        }
      }
    }

    return hijos;
  }

  Future<List<Usuario>> getPadres(Usuario hijo) async {
    List<Usuario> padres = [];
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;

    try {
      documentos = await _db
          .collection('usuarios')
          .doc(hijo.uid)
          .collection('padres')
          .get()
          .then((value) => value.docs);
    } catch (e) {
      print("No tiene padres vinculados. Exeption: $e");
      return [];
    }

    for (var documento in documentos) {
      Map<String, dynamic>? json = await _db
          .collection('usuarios')
          .doc(documento.id)
          .get()
          .then((value) => value.map);
      if (json != null) {
        json['uid'] = documento.id;
        Usuario? padre = Usuario.fromJson(json);
        if (padre != null) {
          padres.add(padre);
        }
      }
    }

    return padres;
  }

  Future<List<Curso>> getCursosPorUsuario(Usuario? usuario) async {
    if (usuario == null) {
      return [];
    }
    List<Curso> cursos = [];
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;

    try {
      documentos = await _db
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('cursos')
          .get()
          .then((value) => value.docs);
    } catch (e) {
      print("No tiene cursos vinculados. Exeption: $e");
      return [];
    }

    for (var documento in documentos) {
      Curso? curso = await getCurso(documento.id);
      if (curso != null) {
        cursos.add(curso);
      }
    }

    return cursos;
  }

  Future<List<Map<String, FormInscripcion>>> getFormulariosInscripcion() async {
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;
    List<Map<String, FormInscripcion>> formularios = [];

    try {
      documentos = await _db
          .collection('formularios_inscripcion')
          .get()
          .then((value) => value.docs);
    } catch (e) {
      print("No hay formularios. Exeption: $e");
      return [];
    }

    for (var documento in documentos) {
      Map<String, dynamic>? json = documento.map;

      if (json != null) {
        FormInscripcion? formulario = FormInscripcion.fromJson(json);

        if (formulario != null) {
          formularios.add({documento.id: formulario});
        }
      }
    }

    return formularios;
  }

  Future<bool> borrarFormularioInscripcion(String id) async {
    try {
      await _db.collection('formularios_inscripcion').doc(id).delete();
      return true;
    } catch (e) {
      print("Error borrando formulario de inscripcion. Exeption: $e");
      return false;
    }
  }

  Future<List<Map<String, Noticia>>> getNoticias() async {
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;
    List<Map<String, Noticia>> noticias = [];

    try {
      documentos =
          await _db.collection('noticias').get().then((value) => value.docs);
    } catch (e) {
      print("No hay noticias. Exeption: $e");
      return [];
    }

    for (var documento in documentos) {
      Map<String, dynamic>? json = documento.map;

      if (json != null) {
        Noticia? noticia = Noticia.fromJson(json);

        if (noticia != null) {
          noticias.add({documento.id: noticia});
        }
      }
    }

    return noticias;
  }

  Future<bool> borrarNoticia(String id) async {
    try {
      await _db.collection('noticias').doc(id).delete();
      return true;
    } catch (e) {
      print("Error borrando Noticia. Exeption: $e");
      return false;
    }
  }

  Future<bool> cargarNoticia(
      String titulo, String contenido, String autor, File? imagen) async {
    Map<String, dynamic> nuevanoticia = {
      'titulo': titulo,
      'contenido': contenido,
      'autor': autor,
      'imagen': ''
    };
    DocRef nuevodocumento;

    try {
      nuevodocumento = await _db.collection('noticias').add(nuevanoticia);
    } catch (e) {
      print("Error cargando nueva noticia. Exeption: $e");
      return false;
    }

    if (imagen != null) {
      try {
        StorageRef rutaImg = _cloud
            .child("noticiasdata")
            .child(await nuevodocumento.get().then((value) => value.id))
            .child("newimage.png");
        UploadTaskForAll subida = rutaImg.putFile(imagen);

        while (true) {
          await for (ProcessTask event in subida.snapshotEvents) {
            if (event.state == TaskState.success) {
              await nuevodocumento.update({'imagen': rutaImg.getDownloadURL()});
              return true;
            } else if (event.state == TaskState.running) {
              //Esperar
            } else {
              print("Error Subiendo Imagen");
              return false;
            }
          }
        }
      } catch (e) {
        print("Error Grabando la Imagen. Exeption: $e");
        return false;
      }
    }

    return true;
  }
}
