import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DisplayData extends StatefulWidget {
  const DisplayData({super.key});

  @override
  State<DisplayData> createState() => _DisplayDataState();
}

class _DisplayDataState extends State<DisplayData> {
  final ScrollController _barController = ScrollController();

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
      webShowClose: false,
    );
  }

  List<String> titles = [
    'Código',
    'Modelo',
    'Memória',
    'Processador',
    'Gráficos',
    'Capacidade de disco',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
  ];

  List<String> texts = [
    '016082',
    'Dell Inc. Inspiron 3583',
    '8.0 GiB',
    'Intel® Core™ i5-8265U CPU @ 1.60GHz x 8',
    'Mesa Intel® UHD Graphics 620 (WHL GT2)',
    '1.0 TB',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
    'TEXTO',
  ];

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Data'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            texts[0],
            style: const TextStyle(
              fontSize: 60,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: currentHeight - 330,
              decoration: BoxDecoration(
                color: const Color(0xFF0093DD),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Colors.black26,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Scrollbar
                child: Scrollbar(              
                  controller: _barController,
                  thickness: 8.0,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    controller: _barController,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: titles.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: index < titles.length - 1
                                  ? Colors.black26
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0), // Textos
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: titles[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '\n\n${texts[index]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0), 
          ),
          ElevatedButton.icon(
            onPressed: (){
              //showToast('Ação realizada com sucesso!');
              Navigator.of(context).pushNamed('/location');
              },
            icon: SvgPicture.asset(
              'assets/images/google_maps_icon.svg',
              width: 24.0,
              height: 24.0,
              ),
            label: const Text('Localização'))
        ],
      ),
    );
  }
}