import 'package:app_am/providers/server_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_am/providers/gps_controller.dart';
import 'package:provider/provider.dart';

final appKey = GlobalKey();

class DisplayData extends StatefulWidget {
  const DisplayData({super.key});

  @override
  State<DisplayData> createState() => _DisplayDataState();
}

class _DisplayDataState extends State<DisplayData> {
  final ScrollController _barController = ScrollController();
  double latitude = 0.0;
  double longitude = 0.0;
  String code = '';
  List<String> titles = [
    'Modelo',
    'Processador',
    'Gráficos',
    'Capacidade de disco'
  ];
  List<String> texts = [];

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

  data(BuildContext context) async {
    final Map<String, dynamic>? dataList = Provider.of<ServerResponseProvider>(context, listen: false).serverResponse;
    debugPrint('Conteúdo de dataList: $dataList');

    if (dataList != null && dataList.isNotEmpty) {
      texts = ['modelo', 'processador', 'graficos', 'armazenamento'].map((key) => dataList[key]?.toString() ?? '').toList();
      code = dataList['codigo'];
      latitude = dataList['latitude'];
      longitude = dataList['longitude'];
    }
  }

  getLocation(BuildContext context, String code, double latitude, double longitude) async {
    GPSController gpsController = Provider.of<GPSController>(context, listen: false);
    if (latitude != 0.0 && longitude != 0.0){
      gpsController.updateITAssetLocation(code, latitude, longitude);
    } else {
      debugPrint('Não há registro de localização para este ativo de TI.');
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    data(context);
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
        const SizedBox(height: 20),
        if (texts.isNotEmpty && texts.length > 1)
          Text(
            code,
            style: const TextStyle(
              fontSize: 60,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: currentHeight/1.65,
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
                  itemCount: texts.isNotEmpty ? titles.length : 0,
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
            getLocation(context, code, latitude, longitude);
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