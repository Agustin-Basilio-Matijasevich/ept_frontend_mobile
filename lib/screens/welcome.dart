import 'package:ept_frontend/screens/asignacion_tutor.dart';
import 'package:ept_frontend/screens/boletin_estudiante.dart';
import 'package:ept_frontend/screens/deuda.dart';
import 'package:ept_frontend/screens/horarios_estudiante.dart';
import 'package:ept_frontend/screens/horarios_tutor.dart';
import 'package:ept_frontend/screens/listado_estudiantes.dart';
// import 'package:ept_frontend/screens/pago_cuotas.dart';
import 'package:ept_frontend/screens/perfil.dart';
import 'package:ept_frontend/widgets/footer.dart';
import 'package:ept_frontend/widgets/login_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';
import 'asignacion_docentes.dart';
import 'asignacion_estudiantes.dart';
import 'boletin_tutor.dart';
import 'creacion_curso.dart';
import 'creacion_usuario.dart';
import 'deudores.dart';
import 'listado_cursos.dart';
import 'listado_usuarios.dart';
import 'notas.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    bool esPantallaChica = MediaQuery.of(context).size.width < 600;
    final usuario = Provider.of<Usuario?>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido a Educar Para Trasformar',
            style: esPantallaChica
                ? const TextStyle(fontSize: 17)
                : const TextStyle(fontSize: null)),
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
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: Image.asset(
                                "assets/images/backgroundWhiteBlur.jpeg")
                            .image,
                        fit: BoxFit.cover,
                        alignment: AlignmentDirectional.bottomCenter,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        _Logo(),
                        _CompanyDescription(),
                      ],
                    ),
                  ),
                  const PageFooter(),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: Image.asset(
                                "assets/images/backgroundWhiteBlur.jpeg")
                            .image,
                        fit: BoxFit.cover,
                        alignment: AlignmentDirectional.bottomCenter,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const _Logo(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 700,
                          child: const _CompanyDescription(),
                        ),
                      ],
                    ),
                  ),
                  const PageFooter(),
                ],
              ),
            );
          }
        },
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
          seccion(context, 'Lista de alumnos', const ListadoEstudiantes(),
              Icons.list),
          seccion(context, 'Horarios', const Horarios(),
              Icons.watch_later_outlined),
          seccion(context, 'Carga de notas', const Notas(), Icons.grade),
        ];
      case UserRoles.estudiante:
        return [
          header,
          profile,
          seccion(context, 'Horarios', const Horarios(),
              Icons.watch_later_outlined),
          seccion(context, 'Boletin', const BoletinEstudiante(), Icons.grade),
        ];
      case UserRoles.padre:
        return [
          header,
          profile,
          seccion(context, 'Pago de cuotas', const Deuda(), Icons.receipt),
          seccion(context, 'Horarios', const HorariosTutor(),
              Icons.watch_later_outlined),
          seccion(context, 'Boletin', const BoletinTutor(), Icons.grade),
        ];
      case UserRoles.nodocente:
        return [
          header,
          profile,
          seccion(context, 'Deudores', const Deudores(), Icons.money_off),
          // Seccion(context, 'Alumnos', Alumnos(), Icons.school),
          // Seccion(
          //     context, 'Horarios', HorariosTutor(), Icons.watch_later_outlined),
          seccion(context, 'Asignación de estudiantes',
              const AsignacionEstudiantes(), Icons.room),
          seccion(context, 'Asignación de docentes', const AsignacionDocentes(),
              Icons.room),
          seccion(context, 'Asignacion de tutores', const AsignacionTutor(),
              Icons.people),
          seccion(context, 'Creación de Usuarios', const CreacionUsuario(),
              Icons.people_outline_sharp),
          seccion(context, 'Creación de Curso', const CreacionCurso(),
              Icons.location_pin),
          seccion(
              context, 'Listado de cursos', const ListadoCursos(), Icons.list),
          seccion(context, 'Listado de usuarios', const ListadoUsuarios(),
              Icons.person),
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
    bool esPantallaChica = MediaQuery.of(context).size.width < 600;
    Usuario? usuario = Provider.of<Usuario?>(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(80, 0, 0, 0),
      child: Text(
        "¡Bienvenido ${usuario?.nombre} \nal sistema de gestión de\neducar para trasformar!",
        softWrap: true,
        textAlign: esPantallaChica ? TextAlign.center : TextAlign.left,
        style: esPantallaChica
            ? const TextStyle(
                //fontFamily:
                color: Color(0xFF0c245e),
                fontSize: 30,
                //fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              )
            : const TextStyle(
                //fontFamily:
                color: Color(0xFF0c245e),
                fontSize: 40,
                //fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    bool esPantallaChica = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(145, 0, 0, 0),
      child: Center(
        child: Image.asset("assets/images/logo.png",
            scale: 1, width: esPantallaChica ? 350 : null),
      ),
    );
  }
}
