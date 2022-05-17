
import 'package:curiosite/model/modelProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _ParamState createState() => _ParamState();
}

class _ParamState extends State<SettingsPage> {


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
                    Text("moteur de recherche: "+(ModelProvider.of(context).searchEngine)),
                    Text("(not impl.)home: "+(ModelProvider.of(context).home)),
                  ][index],),
                  itemBuilder: (BuildContext context)=><List<PopupMenuEntry>>[
                    [
                      PopupMenuItem(
                        child: Text("Google"),
                        onTap: (){
                          setState(() {
                            ModelProvider.of(context).saveEngine("google");
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: Text("Lilo"),
                        onTap: (){
                          setState(() {
                            ModelProvider.of(context).saveEngine("lilo");
                          });
                        },
                      ),
                    ],

                    []
                  ][index]);
            }
        )
    );
  }

}