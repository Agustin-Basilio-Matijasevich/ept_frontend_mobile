import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/curso.dart';

class CursosExpansionPanelList extends StatefulWidget {
  const CursosExpansionPanelList({
    super.key,
    required this.cursos,
    required this.constraints,
  });

  final List<Curso> cursos;
  final BoxConstraints constraints;
  @override
  State<CursosExpansionPanelList> createState() =>
      _CursosExpansionPanelListState();
}

class _CursosExpansionPanelListState extends State<CursosExpansionPanelList> {
  Curso? cursoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          if (isExpanded) {
            cursoSeleccionado = null;
          } else {
            cursoSeleccionado = widget.cursos[index];
          }
        });
      },
      children: widget.cursos
          .map(
            (e) => ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    e.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isExpanded,
                  tileColor: Colors.blue,
                  // selectedTileColor: Colors.blue,
                  textColor: Colors.white,
                );
              },
              isExpanded: (cursoSeleccionado != null &&
                  cursoSeleccionado!.nombre == e.nombre),
              canTapOnHeader: true,
              body: Container(
                width: widget.constraints.maxWidth,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 10,
                    top: 10,
                  ),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Nombre: ${e.nombre} \n'
                    'Aula: ${e.aula} \n'
                    'Dia: ${e.dia.name[0].toUpperCase() + e.dia.name.substring(1)} \n'
                    'Hora Inicio: ${e.horainicio.hour.toString().padLeft(2, '0')}:${e.horafin.minute.toString().padLeft(2, '0')} \n'
                    'Hora Fin: ${e.horafin.hour.toString().padLeft(2, '0')}:${e.horafin.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
