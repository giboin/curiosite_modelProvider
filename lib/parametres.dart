
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Parametres extends StatefulWidget {
  Parametres({Key? key}) : super(key: key);

  @override
  _ParamState createState() => _ParamState();
}

class _ParamState extends State<Parametres> {

  String _engine="google";

  Future<void> _getEngine() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('engine')) {
      return;
    }
    setState(() {
      _engine = prefs.getString('engine') ?? "erreur";
    });
  }

  Future<void> _saveEngine(String str) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('engine', str);
    _getEngine();
  }

  @override
  void initState() {
    super.initState();
    _getEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Paramètres"),),
        body: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: 2,
            separatorBuilder: (BuildContext context,
                int index) => const Divider(height: 3, color: Colors.grey),
            itemBuilder: (BuildContext context, int index) {
              return PopupMenuButton(
                  child: ListTile(title: [
                    Text("moteur de recherche: "+(_engine)),
                    Text("autre chose"),
                  ][index],),
                  itemBuilder: (BuildContext context)=><List<PopupMenuEntry>>[
                    [
                      PopupMenuItem(
                        child: Text("Google"),
                        onTap: (){_saveEngine("google");},
                      ),
                      PopupMenuItem(
                        child: Text("Lilo"),
                        onTap: (){_saveEngine("lilo");},
                      ),
                    ],

                    []
                  ][index]);
            }
        )
    );
  }

}