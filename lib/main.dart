import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/quotations?key=fdf2311c";

void main() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  late double dolar;
  late double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text){
    if (text.isEmpty){
      _clearAll();
    } else {
      double real = double.parse(text);
      dolarController.text = (real/dolar).toStringAsFixed(2);
      euroController.text = (real/euro).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String text){
    if (text.isEmpty){
      _clearAll();
    } else {
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text){
    if (text.isEmpty){
      _clearAll();
    } else {
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        title: const Text("\$ Conversor de moedas \$"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data?["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      const Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      const Divider(),
                      buildTextField("Euros", "EU\$", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function function){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle:const TextStyle(color: Colors.amber),
        enabledBorder:const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber)),
        focusedBorder:const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber)),
        prefixText: prefix,
        prefixStyle:const TextStyle(color: Colors.amber)
    ),
    style:const TextStyle(color: Colors.amber, fontSize: 25),
    onChanged:(value) => function(value),
    keyboardType:const TextInputType.numberWithOptions(decimal: true),
  );
}
