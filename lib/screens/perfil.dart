import 'dart:io';

// import 'package:ept_frontend/services/businessdata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../services/auth.dart';

class Perfil extends StatelessWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    final auth = AuthService();
    Image imagenusr;

    if (usuario!.foto == '') {
      imagenusr = Image.asset('assets/images/defaultProfilePhoto.png');
    } else {
      imagenusr = Image.network(usuario.foto);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          final picker = ImagePicker();
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return FutureBuilder(
                                future: picker.pickImage(
                                  source: ImageSource.gallery,
                                ),
                                builder: (context, snapshot) {
                                  // Obtuvo un archivo
                                  if (snapshot.hasData) {
                                    return FutureBuilder(
                                      future: auth.updateUserImg(
                                        usuario.uid,
                                        File(snapshot.data!.path),
                                      ),
                                      builder: (context, snapshot) {
                                        // El servicio contesto correctamente.
                                        if (snapshot.hasData &&
                                            snapshot.data!) {
                                          Navigator.of(context).pop();
                                          return const SizedBox();
                                        }
                                        // Esta esperando la respuesta del servicio
                                        else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        // El servicio contesto que hubo un error.
                                        else {
                                          return AlertDialog(
                                            title: const Text(
                                                'Actualizacion de foto de perfil'),
                                            content: const Text(
                                                'Ocurrio un error actualizando su foto de perfil'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Aceptar'),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    return const SizedBox();
                                  }
                                },
                              );
                            },
                          );
                        },
                        //padding: EdgeInsets.all(50),
                        child: Container(
                          alignment: Alignment.center,
                          height: constraints.maxHeight * (50 / 100),
                          width: constraints.maxWidth * (80 / 100),
                          decoration: BoxDecoration(
                            border: Border.all(
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: imagenusr,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(50, 50, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nombre: ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            usuario.nombre,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
