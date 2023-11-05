// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_for_all/firebase_for_all.dart';

//Tipos de roles
enum UserRoles {
  estudiante,
  padre,
  docente,
  nodocente,
  norol,
}

class UsuarioBuilder {
  static Future<Usuario> build(User user) async {
    FirestoreItem db =
        FirestoreForAll.instance; //Inicializo instancia de firestore

    //Variables para construir el usuario con valores default
    //Propias
    String uid = user.uid;
    String correo = user.email ?? "anonimo@anonimo.com";
    //FireStore
    UserRoles rol = UserRoles.norol;
    String nombre = "Anonimo";
    String foto = '';

    //Obtener datos de FireStore
    Map<String, dynamic>? userdata;

    try {
      userdata = await db
          .collection('usuarios')
          .doc(uid)
          .get()
          .then((value) => value.map);
    } catch (e) {
      print("Error obteniendo documento de usuario. Exeption: $e");
      userdata = null;
    }
    //Datos de fireStore en variable userdata

    //Si la userdata no es nula tengo que reemplazar los valores default de FireStore
    if (userdata != null) {
      if (userdata['rol'] != null) {
        String srol = userdata['rol'];
        try {
          rol = UserRoles.values
              .firstWhere((element) => element.toString() == srol);
        } catch (e) {
          rol = UserRoles.norol;
        }
      }

      if (userdata['nombre'] != null) {
        nombre = userdata['nombre'];
      }

      if (userdata['foto'] != null) {
        foto = userdata['foto'];
      }
    }

    //Si la userdata es nula quedan los valores default

    //Al final construimos el usuario y lo retornamos
    return Usuario(uid, correo, rol, nombre, foto);
  }
}

//Clase Usuario
class Usuario {
  //Atributos del usuario
  final String uid; //Identificador Unico
  final String correo; //Correo del usuario
  final UserRoles rol; //Rol del usuario
  final String nombre; //NickName
  final String foto; //Foto de Perfil

  Usuario(this.uid, this.correo, this.rol, this.nombre, this.foto);

  static Usuario? fromJson(Map<String, dynamic> json) {
    try {
      final String uid = json['uid'];
      final String correo = json['email'];
      final UserRoles rol = UserRoles.values
          .firstWhere((element) => element.toString() == json['rol']);
      final String nombre = json['nombre'];
      final String foto;

      if (json['foto'] == null) {
        foto = '';
      } else {
        foto = json['foto'];
      }

      return Usuario(uid, correo, rol, nombre, foto);
    } catch (e) {
      print("Error parseando JSON a Usuario. Exeption: $e");
      return null;
    }
  }

  @override
  String toString() {
    return 'UID: $uid, Rol: $rol, Correo: $correo, Nombre: $nombre, Foto: $foto';
  }
}
