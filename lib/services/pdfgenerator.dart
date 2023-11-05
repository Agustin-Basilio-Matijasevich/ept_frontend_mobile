// ignore_for_file: avoid_print

import 'dart:io';
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ept_frontend/models/usuario.dart';

import '../models/curso.dart';
import '../models/pago.dart';

class PDFGenerator {
  static Future<bool> listarAlumnosPorCursoPDF(
      Curso curso, List<Usuario> listaUsuarios, String rutaSalida) async {
    final pdf = pw.Document();
    final file = File(rutaSalida);

    if (listaUsuarios.isEmpty) {
      return false;
    }

    var logo = await rootBundle.load('assets/images/logo.png');

    List<List<String>> data = <List<String>>[
      ['Nombre'],
    ];

    data.addAll(listaUsuarios
        .map(
          (e) => [e.nombre],
        )
        .toList());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Image(
                    pw.MemoryImage(logo.buffer.asUint8List()),
                    width: 250,
                    height: 250,
                  ),
                  pw.Text('Educar para Transformar'),
                ],
              ),
            ),
            pw.Header(
              level: 1,
              child: pw.Center(
                child: pw.Text('Listado de estudiantes'),
              ),
            ),
            pw.Table.fromTextArray(context: context, data: data),
          ];
        },
      ),
    );

    //Añade Paginas

    try {
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print("Error escribiendo archivo. Exeption: $e");
      return false;
    }

    return true;
  }

  static Future<bool> generarComprobantePago(
      Usuario usuario, Pago pago, String rutaSalida) async {
    print(rutaSalida);
    rutaSalida = rutaSalida.replaceAll(r'\"', r'').replaceAll(r'\\', r'\/');
    final pdf = pw.Document();
    final file = File(rutaSalida);

    var logo = await rootBundle.load('assets/images/logo.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Image(
                    pw.MemoryImage(logo.buffer.asUint8List()),
                    width: 250,
                    height: 250,
                  ),
                  pw.Text('Educar para Transformar'),
                ],
              ),
            ),
            pw.Header(
              level: 1,
              child: pw.Text('Comprobante de pago'),
            ),
            pw.Table.fromTextArray(context: context, data: <List<String>>[
              ['Producto', 'Monto', 'Medio de pago', 'Mes de pago'],
              [
                'Servicio de educacion nivel secundario',
                pago.monto.toString(),
                '${pago.tipoPago.name[0].toUpperCase()}${pago.tipoPago.name.substring(1)}',
                pago.fecha.month.toString(),
              ]
            ]),
          ];
        },
      ),
    );

    //Añade Paginas

    try {
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print("Error escribiendo archivo. Exeption: $e");
      return false;
    }

    return true;
  }
}
