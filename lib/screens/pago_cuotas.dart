import 'package:ept_frontend/models/pago.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/businessdata.dart';
import '../services/pdfgenerator.dart';

class PagoCuotas extends StatelessWidget {
  PagoCuotas({Key? key, required this.deudor, required this.deuda})
      : super(key: key);

  Usuario deudor;
  double deuda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago de Cuotas'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: PagoCuotasContenido(
          deudor: deudor,
          deuda: deuda,
        ),
      ),
    );
  }
}

class PagoCuotasContenido extends StatefulWidget {
  PagoCuotasContenido({super.key, required this.deudor, required this.deuda});

  Usuario deudor;
  double deuda;

  @override
  State<PagoCuotasContenido> createState() => _PagoCuotasContenidoState();
}

class _PagoCuotasContenidoState extends State<PagoCuotasContenido> {
  TipoPago? tipoPago;

  final servicio = BusinessData();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownMenu<TipoPago>(
          onSelected: (value) {
            setState(() {
              tipoPago = value;
            });
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(
              label: 'Tarjeta de Credito',
              value: TipoPago.credito,
            ),
            DropdownMenuEntry(
              label: 'Tarjeta de Debito',
              value: TipoPago.debito,
            ),
            DropdownMenuEntry(
              label: 'Efectivo',
              value: TipoPago.efectivo,
            ),
            DropdownMenuEntry(
              label: 'Digital',
              value: TipoPago.digital,
            ),
          ],
        ),
        TextButton(
          child: const Text('Pagar'),
          onPressed: () {
            if (tipoPago != null) {
              var pago = Pago(tipoPago!, widget.deuda, DateTime.now());
              showDialog(
                context: context,
                builder: (context) => FutureBuilder(
                  future: servicio.pagar(widget.deudor, pago),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!) {
                        return AlertDialog(
                          title: const Text('Respuesta creacion pago'),
                          content: const Text(
                              'Exito en la generacion del pago. ¿Desea generar un comprobante?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                bool result;
                                var fileOutput =
                                    await FilePicker.platform.saveFile(
                                  allowedExtensions: ['pdf'],
                                  dialogTitle: 'Guardar comprobante factura',
                                  type: FileType.custom,
                                ).then(
                                  (value) async {
                                    print(value);
                                    result = await PDFGenerator
                                        .generarComprobantePago(
                                      widget.deudor,
                                      pago,
                                      value!,
                                    );
                                    return result;
                                  },
                                ).then(
                                  (value) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        String message = '';
                                        if (value) {
                                          message =
                                              'Se guardo el comprobante exitosamente';
                                        } else {
                                          message =
                                              'Ocurrio un error guardando el pdf';
                                        }
                                        return AlertDialog(
                                          title: const Text(
                                              'Resultado guardado comprobante'),
                                          content: Text(message),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Aceptar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Text('Si'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text('No'),
                            ),
                          ],
                        );
                      } else {
                        return AlertDialog(
                          title: const Text('Respuesta creacion pago'),
                          content: const Text(
                              'Ocurrio un error en la generacion del pago'),
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
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      return const Text('Ocurrio un error');
                    }
                  },
                ),
              );
            }
          },
        )
      ],
    );
  }
}
