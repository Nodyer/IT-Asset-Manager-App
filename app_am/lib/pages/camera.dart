import 'package:app_am/providers/server_response.dart';
import 'package:app_am/providers/url_server.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
//import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:provider/provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  bool _isFlashOn = false;
  Size? size;
  double initialZoom = 1.2;
  double widthBox = 920;
  double heightBox = 360;
  int frameCounter = 0;
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  @override
  void dispose() {
    if (controller != null) {
    controller!.dispose();
    }
    super.dispose();
  }

  void showToast(String message) {
      Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
      webShowClose: false,
    );
  }

  _loadCameras() async {
    try {
      cameras = await availableCameras();
      _startCamera();
    } on CameraException catch (e) {
      debugPrint(e.description);
    }
  }

  _startCamera() {
    if (cameras.isEmpty) {
      debugPrint('Camera not found.');
    } else {
      _previewCamera(cameras[0]);
    }
  }

  _previewCamera(CameraDescription camera) async {
    final CameraController cameraController =
        CameraController(
          camera, ResolutionPreset.max,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420);
    controller = cameraController;

    try {
      await cameraController.initialize();
      if (mounted && controller != null && controller!.value.isInitialized) {
        controller!.setZoomLevel(initialZoom);
        _setFocusAtCenter();
        setState(() {});
      }
    } on CameraException catch (e) {
      debugPrint(e.description);
    }
  }

    void _setFocusAtCenter() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double centerX = screenWidth / 2;
    final double centerY = screenHeight / 2;

    // Normalizar as coordenadas para o intervalo [0.0, 1.0]
    final double normalizedX = centerX / screenWidth;
    final double normalizedY = centerY / screenHeight;
    Offset focusOffset = Offset(normalizedX, normalizedY);

    // Configurar o ponto de foco no centro da tela
    controller!.setFocusPoint(focusOffset);
  }

  _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator()
      );
    } else {
      if (!_isFlashOn && !controller!.value.isStreamingImages) {
      debugPrint('Starting new image stream');
      controller!.startImageStream(_processImageFromStream);
      }
      return SizedBox(
          width: size!.width,
          height: size!.height,
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(height: 4000, width: 2252, child: CameraPreview(controller!)),
          ),
      );
    }
  }

  void _processImageFromStream(CameraImage image) {
    frameCounter++;
    if (mounted && frameCounter == 30) {
      frameCounter = 0;
      int imageWidth = image.width;
      debugPrint("Largura: $imageWidth"); //1280
      int imageHeight = image.height;
      debugPrint("Altura: $imageHeight"); //720

      int cropX = (imageWidth - widthBox) ~/ 2;
      debugPrint("cropX: $cropX"); //410
      int cropY = (imageHeight - heightBox) ~/ 2;
      debugPrint("cropX: $cropY"); //270

      Uint8List croppedBytes = _cropImageBytes(image, cropX, cropY, widthBox.toInt(), heightBox.toInt());
      String base64String = base64.encode(croppedBytes);
      
     if (!_isSendingImage && mounted) {
        _isSendingImage = true;
        _send(base64String, widthBox.toInt(), heightBox.toInt());
      }
    }
  }

  Uint8List _cropImageBytes(CameraImage image, int x, int y, int width, int height) {

    Uint8List originalBytes = image.planes[0].bytes;
    Uint8List croppedBytes = Uint8List(width * height);
    int croppedIndex = 0;

    for (int j = 0; j < height; j++) {
      for (int i = 0; i < width; i++) {
        int originalIndex = (image.width * (j + y) + (i + x));
        croppedBytes[croppedIndex++] = originalBytes[originalIndex];
      }
    }

    return croppedBytes;
}

  _send(String data, int width, int height) async {

    String jsonData = json.encode({
    "frameData": data,
    "width": width,
    "height": height,
    });

    final urlProvider = Provider.of<UrlProvider>(context, listen: false).baseUrl;
    var url = Uri.https(urlProvider, '/camera');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
      );

    if (response.statusCode == 200) {
      debugPrint('Image successfully sent to the server!');
      debugPrint(response.body);
      Provider.of<ServerResponseProvider>(context, listen: false)
        .setServerResponse(response.bodyBytes);
      Navigator.pushReplacementNamed(context, '/display_data');
    } else if (response.statusCode == 422) {
      debugPrint("Erro 422: Invalid data.");
    } else if (response.statusCode == 502) {
      debugPrint("Erro 502: Server Down.");
      showToast('Erro: O servidor está offline');
      Navigator.of(context).pop();
    } else if (response.statusCode == 404) {
      debugPrint("Erro 502: Server Down.");
      showToast('Erro: URL do servidor está incorreto');
      Navigator.of(context).pop();
    } else {
      debugPrint('Error sending image to the server. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
  body: Center(
    child: Stack(
      children: [
        _cameraPreviewWidget(),
        Center(
          child: Container(
            width: heightBox/2,
            height: widthBox/2,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
                strokeAlign: BorderSide.strokeAlignOutside,
                width: size!.height,
              ),
            ),
          ),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
            ),
            RotatedBox(
              quarterTurns: 1,
              child: Text(
                'Posicione a identificação e aguarde o reconhecimento automático',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        Positioned(
          top: 40,
          right: 10,
          child: RotatedBox(
            quarterTurns: 1,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: 10,
          child: RotatedBox(
            quarterTurns: 1,
            child: IconButton(
              icon: _isFlashOn ? const Icon(Icons.flash_off) : const Icon(Icons.flash_on),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  _isFlashOn = !_isFlashOn;
                  if (_isFlashOn) {
                    controller!.setFlashMode(FlashMode.torch); // Ativar o flash
                  } else {
                    controller!.setFlashMode(FlashMode.off); // Desativar o flash
                  }
                });
              },
            ),
          ))
      ],
    ),
  ),
);
}
}