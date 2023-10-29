import 'package:ept_frontend/main.dart';
import 'package:flutter/material.dart';
import 'package:ept_frontend/services/auth.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool esPantallaChica = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue,
      ),
      body: Center(
        child: esPantallaChica
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _Logo(),
                  ContenidoForm(),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: const [
                    Expanded(child: _Logo()),
                    Expanded(
                      child: Center(child: ContenidoForm()),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo.png'),
        const Padding(padding: EdgeInsets.all(16.0)),
      ],
    );
  }
}

class ContenidoForm extends StatefulWidget {
  const ContenidoForm({Key? key}) : super(key: key);
  @override
  State<ContenidoForm> createState() => EstadoContenidoForm();
}

class EstadoContenidoForm extends State<ContenidoForm> {
  final _formKey = GlobalKey<FormState>();
  bool esVisible = false;
  bool recordarContrasenia = false;
  String? email = '';
  String? password = '';
  String? error = '';

  final AuthService auth = AuthService();

  String? emailValidator(String? email) {
    // validacion email
    if (email == null || email.isEmpty) {
      return 'El email no puede estar vacío';
    }
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (!emailValid) {
      return 'Email invalido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              validator: (String? value) {
                if (emailValidator(value) == null) {
                  setState(() {
                    email = value;
                  });
                } else {
                  return emailValidator(email);
                }

                return null;
              },
              onChanged: (val) {
                setState(() => email = val);
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Ingrese su email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña no puede estar vacía';
                }

                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }

                return null;
              },
              onChanged: (String? val) {
                setState(() => password = val);
              },
              obscureText: !esVisible,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Ingrese su contraseña',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon:
                      Icon(esVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      esVisible = !esVisible;
                    });
                  },
                ),
              ),
            ),
            _gap(),
            CheckboxListTile(
              value: recordarContrasenia,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  recordarContrasenia = value;
                });
              },
              title: const Text('Recordarme'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Iniciar Sesion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () async {
                  final bool loginResponse;
                  if (_formKey.currentState!.validate()) {
                    loginResponse = await auth.login(email!, password!);
                    if (loginResponse) {
                    } else {
                      showDialog(
                        context: navigatorKey.currentContext!,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Respuesta Login"),
                            content:
                                const Text("Las credenciales son incorrectas"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Aceptar"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }

                  //Falta vformKeyficar por las cuentas guardadas en firebase.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
