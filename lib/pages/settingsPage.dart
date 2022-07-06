
import 'package:curiosite/model/modelProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _ParamState createState() => _ParamState();
}

class _ParamState extends State<SettingsPage> {

  TextEditingController homePageController = TextEditingController();


  @override
  void didChangeDependencies() {
    homePageController.text=ModelProvider.of(context).home;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {


    List<Widget> children=[
      ListTile(
        leading: const Text("moteur de recherche"),
        title: DropdownButton<String>(
            items: <String>['google','lilo'].map((String value) {
              //La fonction crée un objet qui aura la même valeur et le même texte, à partir du tableau d'objet
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              if(value!=null) {
                ModelProvider.of(context).saveEngine(value);
                setState(() {});
              }
            },
            value: ModelProvider.of(context).searchEngine
        ),
      ),

      ListTile(
        leading: const Text("page d'accueil:"),
        title:TextField(
          controller: homePageController,
          keyboardType: TextInputType.url,
        ),
        trailing: OutlinedButton(
          child: const Text("ok"),
          onPressed: (){
            showDialog(context: context, builder: (BuildContext ctx) {
              return AlertDialog(
                title: const Text("Etes vous sûr.e?"),
                actions: [
                  OutlinedButton(onPressed: (){
                    ModelProvider.of(context).saveHomePage(homePageController.text);
                    Navigator.pop(ctx);
                  }, child: Text("ok")),
                  OutlinedButton(onPressed: (){
                    Navigator.pop(ctx);
                  }, child: Text("nope")),
                ],
              );
            });
          },
        ),
      ),

      ListTile(
          title:Row(
            children: [
              Expanded(
                  child:ListTile(
                    leading: const Text("Cacher http(s)://"),
                    title: Checkbox(
                      value: ModelProvider.of(context).isHttpHidden,
                      onChanged: (value){
                        if(value!=null) {
                          setState(() {
                            ModelProvider.of(context).saveIsHttpHidden(value);
                          });
                        }
                      },
                    ),
                  )
              ),
              Container(width: 1, height: 40,color: Colors.grey,),
              Expanded(
                  child:ListTile(
                    leading: const Text("Cacher www."),
                    title: Checkbox(
                      value: ModelProvider.of(context).iswwwHidden,
                      onChanged: (value){
                        if(value!=null) {
                          setState(() {
                            ModelProvider.of(context).saveIswwwHidden(value);
                          });
                        }
                      },
                    ),
                  )
              )
            ],
          )
      )
    ];


    return Scaffold(
        appBar: AppBar(title: const Text("Paramètres"),),
        body: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: children.length,
            separatorBuilder: (BuildContext context,
                int index) => const Divider(height: 3, color: Colors.grey),
            itemBuilder: (BuildContext context, int index) {
              return children[index];

            }
        )
    );
  }

}