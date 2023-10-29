// ignore_for_file: avoid_print

enum TipoPago {
  credito,
  debito,
  efectivo,
  digital,
}

class Pago {
  final TipoPago tipoPago;
  final double monto;
  final DateTime fecha;

  Pago(this.tipoPago, this.monto, this.fecha);

  static Pago? fromJson(Map<String, dynamic> json) {
    try {
      final TipoPago tipoPago = TipoPago.values
          .firstWhere((element) => element.toString() == json['tipopago']);
      final double monto = double.parse(json['monto'].toString());
      final DateTime fecha = DateTime.parse(json['fecha'].toString());
      return Pago(tipoPago, monto, fecha);
    } catch (e) {
      print("Error parseando JSON a Pago. Exeption: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'tipopago': tipoPago.toString(),
      'monto': monto.toString(),
      'fecha': fecha.toIso8601String()
    };
  }

  @override
  String toString() {
    return 'Tipo de Pago: $tipoPago, Monto: $monto, Fecha del Pago: $fecha';
  }
}
