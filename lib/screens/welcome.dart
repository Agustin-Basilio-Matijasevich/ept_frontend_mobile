import 'package:ept_frontend/screens/boletin_estudiante.dart';
import 'package:ept_frontend/screens/deuda.dart';
import 'package:ept_frontend/screens/horarios_estudiante.dart';
import 'package:ept_frontend/screens/horarios_tutor.dart';
import 'package:ept_frontend/screens/listado_estudiantes.dart';
import 'package:ept_frontend/screens/perfil.dart';
import 'package:ept_frontend/screens/recordatorios/recordatorios.dart';
import 'package:ept_frontend/widgets/login_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';
import 'boletin_tutor.dart';
//import 'notas.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade300,
        foregroundColor: Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          LoginButton(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: seccionesAccesibles(context, usuario!),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  Image.asset("assets/images/backgroundWhiteBlur.jpeg").image,
              fit: BoxFit.cover,
              alignment: AlignmentDirectional.bottomCenter,
            ),
          ),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: const _CompanyDescription(),
        ),
      ),
    );
  }

  List<Widget> seccionesAccesibles(BuildContext context, Usuario usuario) {
    const header = DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Text(
        'Secciones',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );

    final profile = seccion(context, 'Perfil', const Perfil(), Icons.person);

    switch (usuario.rol) {
      case UserRoles.docente:
        return [
          header,
          profile,
          seccion(
              context, 'Recordatorios', Recordatorios(), Icons.calendar_month),
          seccion(context, 'Lista de alumnos', const ListadoEstudiantes(),
              Icons.list),
          seccion(context, 'Horarios', const Horarios(),
              Icons.watch_later_outlined),
        ];
      case UserRoles.estudiante:
        return [
          header,
          profile,
          seccion(
              context, 'Recordatorios', Recordatorios(), Icons.calendar_month),
          seccion(context, 'Horarios', const Horarios(),
              Icons.watch_later_outlined),
          seccion(context, 'Boletin', const BoletinEstudiante(), Icons.grade),
        ];
      case UserRoles.padre:
        return [
          header,
          profile,
          seccion(
              context, 'Recordatorios', Recordatorios(), Icons.calendar_month),
          seccion(context, 'Pago de cuotas', const Deuda(), Icons.receipt),
          seccion(context, 'Horarios', const HorariosTutor(),
              Icons.watch_later_outlined),
          seccion(context, 'Boletin', const BoletinTutor(), Icons.grade),
        ];
      default:
        return [
          header,
          profile,
        ];
    }
  }

  ListTile seccion(BuildContext context, String nombre,
      StatelessWidget pantalla, IconData icono) {
    return ListTile(
      leading: Icon(icono),
      title: Text(nombre),
      onTap: () => {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => pantalla,
          ),
        ),
      },
    );
  }
}

class _CompanyDescription extends StatelessWidget {
  const _CompanyDescription();

  @override
  Widget build(BuildContext context) {
    Usuario? usuario = Provider.of<Usuario?>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: constraints.maxHeight * (50 / 100),
              width: constraints.maxWidth * (80 / 100),
              child: Image.asset("assets/images/logo.png", fit: BoxFit.contain),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                "¡Bienvenido ${usuario?.nombre} al sistema de gestión de educar para trasformar!",
                softWrap: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0c245e),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      },
    );
    // bool esPantallaChica = MediaQuery.of(context).size.width < 600;
    // Usuario? usuario = Provider.of<Usuario?>(context);

    // return Padding(
    //   padding: const EdgeInsetsDirectional.fromSTEB(80, 0, 0, 0),
    //   child: Text(
    //     "¡Bienvenido ${usuario?.nombre} al sistema de gestión de educar para trasformar!",
    //     softWrap: true,
    //     textAlign: esPantallaChica ? TextAlign.center : TextAlign.left,
    //     style: esPantallaChica
    //         ? const TextStyle(
    //             //fontFamily:
    //             color: Color(0xFF0c245e),
    //             fontSize: 30,
    //             //fontStyle: FontStyle.italic,
    //             fontWeight: FontWeight.bold,
    //             fontStyle: FontStyle.italic,
    //           )
    //         : const TextStyle(
    //             //fontFamily:
    //             color: Color(0xFF0c245e),
    //             fontSize: 40,
    //             //fontStyle: FontStyle.italic,
    //             fontWeight: FontWeight.bold,
    //             fontStyle: FontStyle.italic,
    //           ),
    //   ),
    // );
  }
}
