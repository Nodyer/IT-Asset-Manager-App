import 'package:app_am/providers/gps_controller.dart';
import 'package:app_am/home_page.dart';
import 'package:app_am/pages/camera.dart';
import 'package:app_am/pages/about.dart';
import 'package:app_am/pages/display_data.dart';
import 'package:app_am/pages/location.dart';
import 'package:app_am/providers/server_response.dart';
import 'package:app_am/providers/url_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';
import 'color_schemes.g.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  ]);
  await FlutterConfig.loadEnvVariables();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GPSController()),
        ChangeNotifierProvider(create: (context) => UrlProvider('7f8c-177-188-7-250.ngrok-free.app')),
        ChangeNotifierProvider(create: (context) => ServerResponseProvider())
      ],
      child: MaterialApp(
        title: 'TG Nodyer',
        theme: ThemeData(colorScheme: lightColorScheme),
        initialRoute: '/',
        routes: {
          '/': (context) => const MyHomePage(title: 'Gerenciador de Ativos de TI - FEB'),
          '/camera': (context) => const CameraPage(),
          '/about': (context) => const AboutPage(),
          '/display_data': (context) => const DisplayData(),
          '/location': (context) => const LocationPage(),
        },
      ),
    );
  }
}
