import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartbill/screens/splash/splash.dart';
import 'package:smartbill/services.dart/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDPK3kX-TfPeKY_qKAqoi81VRTiII7tPRc",
      appId: "1:1005746669910:android:720e57be651775f90e2ef7",
      messagingSenderId: "1005746669910",
      projectId: "smartbill-flutter"
    )
  );
  
  runApp(StreamProvider.value(value: AuthService().user, initialData: null, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      title: 'Smartbill',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
    );
  }
}

