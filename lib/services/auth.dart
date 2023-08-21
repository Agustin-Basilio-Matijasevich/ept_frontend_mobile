import 'package:firebase_auth/firebase_auth.dart';
import 'package:ept_frontend/models/usuario.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance; //Define la instancia de autenticacion para firebase

  //Crea Usuario. Si el usuario viene null entonces devuelve null
  Usuario? _builduser (User? usuario) {
    if (usuario != null) {
      return Usuario(uid: usuario.uid);
    } else {
      return null;
    }
  }

  //Servicio de escucha para estado de usuario, devuelve Usuario o null
  Stream<Usuario?> get usuario
  {
    return _auth.authStateChanges().map(_builduser); //Mas fachero papa
    //.map((User? usuario) => _builduser(usuario)); //feofeofeo
  }

  //Log in con email y clave si el usuario no puede loguearse devuelve null, si se loguea devuelve el tipo usuario de firebase
  Future login(String email, String password) async {
    try {
      UserCredential credencial = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print(credencial.toString());
      User? usuario = credencial.user;
      print(usuario.toString());
      return _builduser(usuario);

    } catch(e) {
      print(e.toString());
      return null;

    }

  }

  //sign out
  Future logout() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }

}