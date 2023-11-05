import 'package:ept_frontend/models/usuario.dart';
import 'package:ept_frontend/services/auth.dart';
import 'package:ept_frontend/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_for_all/firebase_for_all.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreForAll.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      firestore: true,
      auth: true,
      storage: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget inicial de la aplicacion
  @override
  Widget build(BuildContext context) {
    // La aplicacion se construye siendo hija del stream que escucha el estado del usuario de esa manera tenemos en el contexto de la aplicacion disponible la data de usuario invocando al provider
    return StreamProvider<Usuario?>.value(
      value: AuthService().usuario,
      initialData: null,
      child: MaterialApp(
        title: 'Educar Para Transformar',
        debugShowCheckedModeBanner: false,
        //scrollBehavior: ScrollBehavior(),
        home: const Wrapper(),
        navigatorKey: navigatorKey,
      ),
    );
  }
}
