import 'package:ept_frontend/models/recordatorio.dart';
import 'package:ept_frontend/models/usuario.dart';
import 'package:firebase_for_all/firebase_for_all.dart';

class RecordatoriosService {
  final FirestoreItem _db = FirestoreForAll.instance; //Inicializo instancia de firestore

  Future<bool> grabaRecordatorio (Usuario usuario, Recordatorio recordatorio) async {
    ColRef coleccion = _db.collection("usuarios").doc(usuario.uid).collection("recordatorios");

    Map<String, dynamic> json = recordatorio.toJson();

    try {
      await coleccion.add(json);
    } catch (e) {
      print("Error grabando Recordatorio. Exeption: $e");
      return false;
    }

    return true;

  }

  //Necesito el id que te doy en el get junto a cada recordatorio para poder borrarlo
  Future<bool> borraRecordatorio (Usuario usuario, String idRecordatorio) async {
    try {
      await _db.collection("usuarios").doc(usuario.uid).collection("recordatorios").doc(idRecordatorio).delete();
    } catch (e) {
      print("Error Borrando Recordatorio. Exeption: $e");
      return false;
    }

    return true;
  }

  Future<List<Map<String,Recordatorio>>> getRecordatorios (Usuario usuario) async {
    List<Map<String,Recordatorio>> recordatorios = [];
    List<DocumentSnapshotForAll<Map<String, Object?>>> documentos;

    try {
      documentos = await _db.collection("usuarios").doc(usuario.uid).collection("recordatorios").get().then((value) => value.docs);
    } catch (e) {
      print("Error obteniendo Recordatorios de DB. Exeption: $e");
      return [];
    }

    for (var documento in documentos)
      {
        Map<String, dynamic>? json = documento.map;

        if (json != null)
          {
            Recordatorio? recordatorio = Recordatorio.fromJson(json);

            if (recordatorio != null)
              {
                recordatorios.add({documento.id : recordatorio});
              }

          }

      }

    return recordatorios;

  }

}

