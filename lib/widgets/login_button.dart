import 'package:ept_frontend/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:ept_frontend/screens/login.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';

class LoginButton extends StatelessWidget {
  final _auth = AuthService();
  LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    Usuario? user = Provider.of<Usuario?>(context);
    if (user == null) {
      return TextButton.icon(
        style: const ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(Colors.white),
        ),
        icon: const Icon(Icons.person),
        label: const Text(
          'Ingresar',
          style: TextStyle(fontSize: 18),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        },
      );
    } else {
      if (user.foto != '') {
        return TextButton.icon(
          style: const ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.white),
          ),
          icon: Image.network(
            user.foto,
            width: 32,
            height: 32,
          ),
          label: Text(
            'Hola, ${user.nombre}',
            style: const TextStyle(fontSize: 18),
          ),
          onPressed: () {
            _auth.logout();
          },
        );
      } else {
        return TextButton.icon(
          style: const ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.white),
          ),
          icon: Image.asset(
            'assets/images/defaultProfilePhoto.png',
            width: 32,
            height: 32,
          ),
          label: Text(
            'Hola, ${user.nombre}',
            style: const TextStyle(fontSize: 18),
          ),
          onPressed: () {
            _auth.logout();
          },
        );
      }
    }
  }
}
