import 'package:flutter/material.dart';

import '../../models/curso.dart';

class NotasExpansionPanelList extends StatefulWidget {
  const NotasExpansionPanelList({
    super.key,
    required this.notas,
    required this.constraints,
  });

  final List<Map<Curso, List<int?>>> notas;
  final BoxConstraints constraints;

  @override
  State<NotasExpansionPanelList> createState() =>
      _NotasExpansionPanelListState();
}

class _NotasExpansionPanelListState extends State<NotasExpansionPanelList> {
  int? getPromedio(Iterable<int?> notas) {
    int sumatoria = 0;
    int cantNotas = 0;
    for (var nota in notas) {
      if (nota != null) {
        sumatoria += nota;
        cantNotas++;
      }
    }
    if (cantNotas == 0) {
      return null;
    } else {
      return (sumatoria / cantNotas).round();
    }
  }

  Curso? cursoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (panelIndex, isExpanded) {
        setState(() {
          if (isExpanded) {
            cursoSeleccionado = null;
          } else {
            cursoSeleccionado = widget.notas[panelIndex].keys.first;
          }
        });
      },
      children: widget.notas
          .map(
            (e) => ExpansionPanel(
              headerBuilder: (context, isExpanded) => ListTile(
                title: Text(
                  e.keys.first.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isExpanded,
                tileColor: Colors.blue,
                // selectedTileColor: Colors.blue,
                textColor: Colors.white,
              ),
              isExpanded: (cursoSeleccionado != null &&
                  cursoSeleccionado!.nombre == e.keys.first.nombre),
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
                    'Primer trimestre: ${(e.values.first[0] == null) ? '-' : e.values.first[0]} \n'
                    'Segundo trimestre: ${(e.values.first[1] == null) ? '-' : e.values.first[1]}\n'
                    'Tercer trimestre: ${(e.values.first[2] == null) ? '-' : e.values.first[2]}\n'
                    'Promedio: ${(getPromedio(e.values.first) == null) ? '-' : getPromedio(e.values.first)}',
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
