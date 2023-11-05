import 'package:ept_frontend/models/usuario.dart';
import 'package:ept_frontend/screens/login.dart';
import 'package:ept_frontend/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario =
        Provider.of<Usuario?>(context); //Escucha si el usuario esta logueado

    //Retorna pantalla de home segun si estas logueado o no
    if (usuario == null) {
      return const Login();
    } else {
      return const Welcome();
    }
  }
}
