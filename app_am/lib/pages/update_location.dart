import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateLocation extends StatelessWidget {
  const UpdateLocation({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 400,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Deseja atualizar a localização?',
            style: TextStyle(
              fontSize: 15,
              decoration: TextDecoration.none,
            ),),
            Padding(padding: EdgeInsets.all(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {
                  showToast('Localização atualizada');
                  Navigator.of(context).pop();
                  }, 
                  child: Text('Sim')),
                Padding(padding: EdgeInsets.all(10)),
                OutlinedButton(onPressed: () {
                  Navigator.of(context).pop();
                },
                  child: Text('Cancelar'))
              ],
            )
          ],
        ),
      ),
    );
  }
}