import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ept_frontend/models/usuario.dart';
import 'package:firebase_for_all/firebase_for_all.dart';

import '../firebase_options.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuthForAll
      .instance; //Define la instancia de autenticacion para firebase
  final FirestoreItem _db =
      FirestoreForAll.instance; //Inicializo instancia de firestore
  final StorageRef _storageRef =
      FirebaseStorageForAll.instance.ref();

  //Metodo para obtener el usuario personalizado mediante la escucha de un stream
  Stream<Usuario?> get usuario {
    return _auth.userChanges().asyncMap((user) => _builduser(user)); //Retorna la escucha del servicio de estado de autenticacion de firebase que contiene el usuario de firebase, pero antes lo pasa por el costructor de usuario personalizado
  }

  //Metodo Constructor de usuario personalizado, recibe como parametro el usuario de firebase y devuelve el usuario personalizado, si el parametro es null, devuelve null.
  Future<Usuario>? _builduser(User? user) {
    if (user != null) {
      return UsuarioBuilder.build(user);
    } else {
      return null;
    }
  }

  //Metodo para loguear un usuario con email y password
  //Codigos de respuesta: Booleano. True para exito y false para error
  Future<bool> login(String email, String password) async {
    try //Usamos try para detectar si hay un error con la conexion al Backend
    {
      await _auth.signInWithEmailAndPassword(
          email: email,
          password: password); //Tiramos la request y esperamos que responda
      return true;
    } catch (e) {
      return false;
    }
  }

  //Metodo para desloguear usuario
  //Este metodo no tiene respuesta, solo debe esperarse a que termine con un await y luego el provider del contexto de la aplicacion actualiza la data de usuario a nulo quitando el acceso a los mismos a toda la app
  Future<void> logout() async {
    await _auth
        .signOut(); //Tiramos la reques de logout y esperamos que responda
  }

  //Crear Usuario
  Future<bool> createUser(
      String email, String password, UserRoles rol, String nombre) async {
    User nuevoUsuario;

    try {
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credencial.user != null) {
        nuevoUsuario = credencial.user!;
      } else {
        throw Exception("Usuario Nulo");
      }

    } catch (e) {
      print("Error creando nuevo Usuario en Firebase");
      print("Email: $email, Password: $password");
      print("Exepcion: $e");
      return false;
    }

    Map<String, String> userdata = {'nombre': nombre, 'rol': rol.toString(), 'email' : email};

    try {
      await _db.collection("usuarios").doc(nuevoUsuario.uid).set(userdata);
    } catch (e) {
      await nuevoUsuario.delete();
      print("Error cargando datos de usuario a Firebase");
      print("Nombre: $nombre, Rol: $rol");
      print("Exepcion: $e");
      return false;
    }

    await logout();

    return true;
  }

  //Actualizar Imagen de usuario
  Future<bool> updateUserImg(String userId, File foto) async {
    StorageRef rutaImg = _storageRef.child("usersdata").child(userId).child("defaultProfilePhoto.png");
    DocRef userdata = _db.collection("usuarios").doc(userId);
    String imgUrl;

    UploadTaskForAll subida = rutaImg.putFile(foto);

    while(true) {
      await for (ProcessTask event in subida.snapshotEvents) {
        if (event.state == TaskState.success) {
          try {
            imgUrl = await rutaImg.getDownloadURL();
            await userdata.update({'foto': imgUrl});
            await _auth.currentUser!.reload();
            return true;
          }
          catch (e) {
            print("Error grabando imagen o credenciales vencidas. Exepcion: $e");
            logout();
            return false;
          }
        }
        else if (event.state == TaskState.running) {
          //Esperar
        }
        else {
          print("Error Subiendo Imagen");
          return false;
        }
      }
    }

  }

}
