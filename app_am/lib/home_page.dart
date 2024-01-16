import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
                top: 200,
                child: SizedBox(
                width: 300,
                child: Image.asset('assets/images/logo_unesp2.png')
                ),
              ),
            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [  
              ElevatedButton.icon(
                onPressed: () => {
                  Navigator.of(context).pushNamed('/camera')
                },
                icon: const Icon(Icons.camera_alt),
                label: const Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text('COMEÇAR'),
                ),
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    fixedSize: const Size(300, 50),
                    textStyle: const TextStyle(
                      fontSize: 20,
                    )),
              ),
            ],
          ),
          Positioned(
            bottom: 265,
            child: Column(
              children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/display_data'),
                    style: OutlinedButton.styleFrom(fixedSize: const Size(300, 30)),
                    child: const Text('TUTORIAL')),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/about'),
                    style: OutlinedButton.styleFrom(fixedSize: const Size(300, 30)),
                    child: const Text('SOBRE'))
              ],
            ))
        ]),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
