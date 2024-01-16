import 'package:flutter/material.dart';
import 'package:awesome_icons/awesome_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Uri _url = Uri.parse('https://github.com/Nodyer/IT-Asset-Manager-App');

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voltar'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: 80,
            ),
            const Text('Sobre',
            style: TextStyle(
              fontSize: 60,
            ),),
            Container(
              height: 70,
            ),
            SizedBox(
              width: 350,
              child: RichText(textAlign: TextAlign.justify, text: const TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 15, height: 1.5,),
              children: [
                TextSpan(text: 'O aplicativo tem como propósito a implementação de técnicas de Visão Computacional para a identificação de ativos de Tecnologia da Informação (TI), a partir unidade administrativa, código de barra e número de identificação. Ele oferece aos usuários a capacidade de consultar informações detalhadas About os ativos, assim como a possibilidade de atualizar a sua localização.\n\n'),
                TextSpan(text: 'Este projeto faz parte do Trabalho de Graduação em Engenharia Elétrica, desenvolvido por Nodyer H. N. dos Anjos, sob a orientação do Dr. Prof. José Eduardo Cogo Castanho, com uma aplicação prática na Universidade Estadual Paulista (UNESP) na Faculdade de Engenharia de Bauru (FEB).')
              ]),),
            ),
            Container(
              height: 80,
            ),
            Container(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: () => {
                launchUrl(_url,
                  mode: LaunchMode.inAppBrowserView)
              },
              icon: const Icon(FontAwesomeIcons.github),
              label: const Padding(
                padding: EdgeInsets.all(0.0),
                child: Text('Github'),
              ),
              style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  fixedSize: const Size(350, 45),
                  textStyle: const TextStyle(
                    fontSize: 20,
                )),
            )
        ]),
    )
  );
  }
}